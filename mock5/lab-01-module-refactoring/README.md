# 实验 01：保留状态的模块重构

> 独立的 Terraform Professional 风格练习实验，不代表 HashiCorp 官方考试题目。

## 场景

一个小型运维平台已经运行在兼容 AWS 的基础设施上。其 Terraform 配置仍是单一的旧版根模块，本地状态包含全部资源。你的任务是将配置重构为四个子模块，在两个根模块之间划分资源归属，将状态迁移到两个 S3 后端 key，并确保整个过程不替换任何现有基础设施。

**建议用时：**70–80 分钟
**目标难度：**90–95 / 100
**主要环境：**Terraform CLI 1.11.x、Docker Desktop、Docker Compose 和 LocalStack

可见的 AWS 结果并不是唯一验收标准。下方的精确实现要求会分别进行检查。

## 开始与安全规则

1. 按照 `ENVIRONMENT.md` 中的说明初始化环境。
2. 只能在 `student/` 中工作。
3. 将所有已有远端对象和标识符视为必须保留的基础设施。
4. 不得手动编辑 Terraform 状态 JSON。
5. 不得使用宽泛的 `lifecycle.ignore_changes` 来掩盖漂移。
6. 不得用其他资源类型替换要求的资源类型，即使最终 AWS 对象看起来等价。
7. 不得硬编码 ID、生成的名称或中间输出值。
8. 接受任何 plan 前，都必须检查创建、更新、删除和替换操作。

## 最终目录结构

`student/` 下最终必须严格使用以下根模块和子模块目录：

```text
student/
├── infra/
│   ├── application/
│   └── shared/
└── modules/
    ├── compute/
    ├── identity/
    ├── network/
    └── security/
```

每个子模块目录都必须包含 `main.tf`、`variables.tf` 和 `outputs.tf`。题目提供了模块草稿文件，但其接口不一定符合本实验要求。

## 任务 1：建立基线

检查 `student/` 中的旧版根模块。确认其状态包含已有 VPC、两个带索引的子网、三个带 key 的安全组、带 key 的入站规则、IAM 资源、两个带 key 的实例、两个存储桶、一个需要保留的对象，以及一个用于生成名称的资源。

记录初始资源地址，并确认初始 plan 报告 **0 to add, 0 to change, and 0 to destroy**。以下物理标识符在整个实验中必须保持不变：

- VPC ID
- 两个子网 ID
- 所有安全组 ID
- 两个 EC2 实例 ID
- IAM 角色名和实例配置文件名
- artifact 存储桶名称
- 保留对象的 key

## 任务 2：重构为指定的子模块边界

最终子模块必须满足下表的全部要求。表中的 block 数量指 Terraform `resource` block 数量，而不是实例数量。

| 子模块 | 必需文件 | 必需资源类型及 block 数量 | 必需管理范围 |
|---|---|---|---|
| `modules/network` | `main.tf` | 恰好 1 个 `aws_vpc` block 和 1 个 `aws_subnet` block | 已有 VPC 和两个已有子网；子网 block 必须使用 `count` |
| `modules/security` | `main.tf` | 恰好 1 个 `aws_security_group` block 和 1 个 `aws_vpc_security_group_ingress_rule` block | 三个已有安全组及所有已有入站规则；两个 block 都必须使用 `for_each` |
| `modules/identity` | `main.tf` | 恰好 1 个 `aws_iam_role` block 和 1 个 `aws_iam_instance_profile` block | 已有运行时角色和配置文件 |
| `modules/compute` | `main.tf` | 恰好 1 个 `aws_instance` block | 两个已有实例；block 必须使用原有稳定字符串 key 的 `for_each` |

以上四个模块都是必需的。即使 Terraform 生成了正确的基础设施，将多个模块的职责合并为更少的模块也不符合要求。

子模块不得读取兄弟模块的内部实现。跨模块值必须经由根模块传递。子模块不得包含 provider block、backend block 或 `terraform_remote_state` 数据源。

## 任务 3：修复接口与依赖关系

子模块必须使用以下精确的输出接口：

| 模块 | 输出名称 | 必需类型及含义 |
|---|---|---|
| `network` | `vpc_id` | `string`，来自受管 VPC |
| `network` | `subnet_ids` | `map(string)`，以输入定义中的 segment key 为 key |
| `security` | `security_group_ids` | `map(string)`，以 tier 名称为 key |
| `identity` | `role_name` | `string`，来自受管 IAM 角色 |
| `identity` | `instance_profile_name` | `string`，来自受管实例配置文件 |
| `compute` | `instance_ids` | `map(string)`，以 workload role 为 key |

依赖关系必须如下：

- `security` 从 shared 根模块接收 VPC ID。
- `compute` 接收子网 ID map。
- `compute` 接收安全组 ID map。
- `compute` 从 `identity` 接收实例配置文件名称。
- `identity` 通过 application 根模块接收生成的 shared 命名 token。
- 不得用硬编码 ID 或复制的状态值替代上述接口。

部分草稿接口可以通过在根模块中重新组织值来运行，但如果这种做法违反了指定的输入/输出语义，则不予接受。

## 任务 4：变更地址但保留所有资源

将每个旧版状态地址迁移到最终归属模型所对应的地址。结果必须覆盖：

- 普通单例地址；
- 带索引的 `count` 地址；
- 带 key 的 `for_each` 地址；
- 从旧版根模块迁移到子模块的地址；
- 迁移到不同最终状态文件的地址。

最终状态中不得保留原根模块的任何旧版受管资源地址。以同名资源先销毁再创建的结果视为失败。即使内容不变，重新上传保留的 S3 对象也视为失败。

## 任务 5：将资源归属拆分到两个根模块

### Shared 根模块

`student/infra/shared` 必须调用 `network` 和 `security`，并且只能由它管理以下资源：

- 恰好 1 个 `random_pet` block；
- 恰好 2 个 `aws_s3_bucket` block；
- 恰好 1 个 `aws_s3_object` block。

其 S3 后端 key 必须严格为：

```text
tfpro-sim/lab-01/shared.tfstate
```

Shared 根模块必须暴露以下精确输出：

| 输出名称 | 必需类型 |
|---|---|
| `network_id` | `string` |
| `subnet_ids_by_zone` | `map(string)` |
| `security_group_ids_by_tier` | `map(string)` |
| `shared_name_token` | `string` |
| `artifact_bucket_name` | `string` |
| `retained_object_key` | `string` |

每个值都必须来自受管资源或子模块输出。硬编码输出值不符合要求。

### Application 根模块

`student/infra/application` 必须调用 `identity` 和 `compute`。其 S3 后端 key 必须严格为：

```text
tfpro-sim/lab-01/application.tfstate
```

Application 根模块必须通过根模块 `.tf` 文件中的恰好 1 个 `terraform_remote_state` 数据 block 读取 shared 根模块。子模块不得读取远程状态。

它必须暴露以下精确输出：

| 输出名称 | 必需类型 |
|---|---|
| `instance_ids_by_role` | `map(string)` |
| `instance_profile_name` | `string` |

## Provider 身份与后端要求

两个根模块都只能使用各自根模块中声明的默认 `hashicorp/aws` provider 配置。所有受管 AWS 资源，包括子模块中的资源，都必须继承该默认 provider 身份。provider alias、子模块 provider block、默认主机凭据，以及直接写入受管资源的凭据，均不属于本实验要求的实现方式。

对于 LocalStack，根模块 provider 配置必须使用模拟器 endpoint 和 `ENVIRONMENT.md` 中记录的非敏感占位凭据。两个 S3 后端都必须使用已有的 `tfpro-lab01-state-archive` 存储桶、path-style 访问，以及上文规定的精确 key。最终状态不得留在本地。

## 最终验收条件

1. Shared 和 application 状态只包含各自归属范围内的资源。
2. 基线中列出的资源 ID 均未发生变化。
3. 保留对象没有被删除、替换或重新上传。
4. 两个最终 plan 都报告 0 add、0 change、0 destroy。
5. 资源类型、block 数量、文件位置、输出名称、输出类型、模块边界、provider 身份和后端 key 均符合本文档。
6. 不存在宽泛的 `ignore_changes`、硬编码中间输出、重复归属或子模块远程状态访问。
