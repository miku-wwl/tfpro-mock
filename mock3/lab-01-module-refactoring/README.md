# Lab 01 — 按边界进行 Module 重构

> 这是一个独立的 Terraform Professional 风格练习实验，并非 HashiCorp 官方考试题。

## 建议用时

70–80 分钟。

## 场景

平台团队接手了一个可正常工作的 Terraform root module。当前配置把网络、安全边界、provider 访问角色、计算工作负载和制品归档全部放在同一个 state 中。计时开始前，基础设施已经存在。

你的任务是在不替换任何受管基础设施的前提下重构配置，同时保留严格的 AWS 身份边界。即使配置能够成功 apply，只要 profile、alias、region、provider 映射、state 位置或 lock 文件约束错误，也不算完成。

## 环境

- Terraform CLI 1.11.x；
- Docker Desktop 和 Docker Compose；
- LocalStack；
- Bash 或 Windows PowerShell。

开始计时前运行初始化脚本：

```bash
./scripts/setup.sh
```

```powershell
./scripts/setup.ps1
```

初始化过程会创建已有的 LocalStack 资源，将 state 复制到 `student/`，并记录基线信息。本实验中的凭证仅为 LocalStack 使用的虚拟凭证。

## 身份配置要求

最终的两个 root module 必须通过以下相对于 root 的精确路径加载文件：

- 共享 config：`${path.root}/../../.aws/config`；
- 共享 credentials：`${path.root}/../../.aws/credentials`。

文件必须包含以下配置：

| Profile | `source_profile` | 精确 role ARN | Region | 用途 |
|---|---|---|---|---|
| `fabric-admin` | `local-base` | `arn:aws:iam::000000000000:role/Lab01NetworkOperator` | `us-east-1` | VPC、子网、安全组、state bucket |
| `workload-admin` | `local-base` | `arn:aws:iam::000000000000:role/Lab01WorkloadOperator` | `us-east-1` | IAM 和 EC2 |
| `archive-admin` | `local-base` | `arn:aws:iam::000000000000:role/Lab01ArchiveOperator` | `us-west-2` | 制品 bucket 和对象 |
| `observer` | `local-base` | `arn:aws:iam::000000000000:role/Lab01ReadOnlyObserver` | `us-east-1` | 只读 data source |

credentials 文件只能包含 `local-base` source profile，不得添加 `default` profile，也不得在 provider block 中用静态凭证替代这些 profile。

## Provider 要求

最终配置必须使用以下 AWS provider alias：

- `aws.network`
- `aws.workload`
- `aws.archive`
- `aws.readonly`

每个子模块都必须声明自己使用的 alias，每个 root module 调用都必须显式提供 `providers` 映射。至少两个子模块必须使用 `configuration_aliases`。caller-identity data source 必须使用 `aws.readonly`，即使使用未命名的高权限 provider 也能得到结果。

归档资源必须位于 `us-west-2`，其他 AWS 资源位于 `us-east-1`。

## 初始结构

实验从 `student/` 中的有效单体配置开始，大多数受管资源位于 `combined.tf`。`refactor-draft/` 包含平台团队提供的、看似合理但实际错误的片段。除非你将它们适配到目标结构，否则这些片段不会被 Terraform 加载。

修改配置或 state 前，先确认初始 plan 为：

```text
0 to add, 0 to change, 0 to destroy
```

## 目标结构

```text
student/
├── .aws/
├── infra/
│   ├── shared/
│   └── application/
└── modules/
    ├── network/
    ├── security/
    ├── identity/
    └── compute/
```

每个子模块都必须包含 `main.tf`、`variables.tf` 和 `outputs.tf`。

## 任务 1 — 建立基线

1. 检查当前生效的配置和 state；
2. 确认初始 plan 为 `0 to add, 0 to change, 0 to destroy`；
3. 记录普通资源、`count` 实例和 `for_each` 实例的当前地址；
4. 保留 `baseline/` 中记录的 ID；
5. 不得删除、替换或重新创建任何已有资源。

## 任务 2 — 重构为子模块

| Module | 职责 | 必需 AWS alias |
|---|---|---|
| `network` | VPC 和子网 | `aws.network` |
| `security` | 安全组、入站规则、出站规则、只读 caller identity | `aws.network`、`aws.readonly` |
| `identity` | provider 访问角色、工作负载角色、instance profile | `aws.workload` |
| `compute` | EC2 实例 | `aws.workload` |

要求：

- 子模块不得直接引用兄弟模块中的资源；
- 跨模块数据必须通过 root module 的 typed input/output 传递；
- 不得硬编码云资源 ID 或 provider 推导出的 AWS account ID；
- 子模块不得意外声明默认 AWS provider；
- root module 必须显式映射所有需要的 provider alias。

## 任务 3 — 修复依赖和草稿缺陷

构建目标结构时，同时修复提供的重构片段。最终数据流必须满足：

- security module 从 network module 接收 VPC ID；
- compute module 接收子网 ID、安全组 ID 和 instance profile 名称；
- identity module 接收共享命名值和观测到的 AWS account ID；
- 至少一个子模块使用另一个模块输出的 map；
- 共享命名值继续影响两个最终 state 中的资源。

草稿中包含多种独立缺陷，包括集合使用错误、对象属性错误、变量契约不匹配、未声明参数、遗漏 provider 映射，以及可能在错误身份下运行的 data source。请修复这些问题，不要用宽泛的 `ignore_changes` 掩盖它们。

## 任务 4 — 迁移资源地址

将每个已有 state 对象对齐到最终 module 地址，不得重新创建基础设施。

迁移必须覆盖：

- 普通资源；
- `count` 实例；
- 使用字符串 key 的 `for_each` 实例；
- 迁移到子模块地址的资源；
- 后续需要拆分到不同 root state 的资源。

最终 state 中不得保留 `student/combined.tf` 产生的旧 root 地址。

## 任务 5 — 拆分 root 和 state

### `infra/shared`

负责管理：

- network module；
- security module；
- 共享随机命名资源；
- 制品 bucket 和对象；
- remote-state bucket。

backend key 必须精确为：

```text
tfpro-sim/lab-01/shared.tfstate
```

### `infra/application`

负责管理：

- identity module；
- compute module。

backend key 必须精确为：

```text
tfpro-sim/lab-01/application.tfstate
```

application root 必须通过 `terraform_remote_state` 使用 shared 输出；子模块不得包含 remote-state data source。

两个 state 不得同时管理同一资源。shared 资源不能继续存在于 application state，application 资源也不能存在于 shared state。

## 任务 6 — Provider 版本和 lock 文件

两个最终 root 都必须满足：

- AWS provider 约束为 `~> 5.90.0`；
- 仅在使用 Random provider 的 root 中要求 `3.6.3`；
- 刷新 `.terraform.lock.hcl`；
- 保留 AWS `5.90.0` 的 lock 条目；
- 不得提交 provider 二进制文件或 `.terraform/`。

过期的 lock 约束、缺失的平台 checksum，或意外选择 AWS 6.x provider 都不符合要求。

## 完成条件

只有满足以下全部条件，实验才算完成：

1. 两个最终 root 都能使用精确 backend key 成功初始化；
2. 两个最终 root 都能通过 validate；
3. 两个最终 plan 都为 `0 to add, 0 to change, 0 to destroy`；
4. 没有任何基线资源 ID 发生变化；
5. provider alias、profile、source profile、role ARN、region、文件路径、module provider 映射和 state provider 地址都符合本 README；
6. caller-identity data source 通过 `aws.readonly` 执行；
7. 不存在旧地址；
8. 没有用宽泛的 lifecycle 规则掩盖依赖或 state 错误。

完成后可使用 `CHECKS.md` 中的命令进行复核。完整的 state 迁移步骤不会放在 Student 包中。
