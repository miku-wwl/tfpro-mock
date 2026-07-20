# Terraform Professional 模拟考试 — Lab 01：模块重构

> 本材料仅供独立练习，并非 HashiCorp 官方考试题目。

## 场景

某平台团队已经有一套可以正常工作的 Terraform 单体配置，用于管理现有的 LocalStack 环境。目前执行 `terraform plan` 时不会产生任何变更。你的任务是在不替换任何现有基础设施的前提下，将这套配置重构为可复用的子模块，并进一步拆分为两个相互独立的根模块进行管理。

**目标完成时间：** 70–80 分钟
**推荐 Terraform CLI 版本：** 1.11.x

## 安全要求与完成条件

* 将当前已纳入管理的所有资源视为现有的、接近生产环境的资源。
* 不得销毁、替换或重新创建任何已管理资源。
* 不得直接修改 Terraform state JSON 文件。
* 不得通过大范围的生命周期忽略规则来掩盖配置漂移。
* 必须保留初始化过程中记录的所有资源标识符。
* 最终两个根模块的 `plan` 结果都必须显示：无新增、无变更、无删除。

## 环境准备

在 Lab 根目录中，根据你使用的 Shell 运行对应的初始化脚本：

```bash
./scripts/setup.sh
```

```powershell
./scripts/setup.ps1
```

初始化过程会启动 LocalStack、创建基线基础设施、准备学生使用的单体 Terraform state，并将基线证据保存到 `student/baseline/` 目录中。

---

## 任务 1 — 建立基线

1. 检查 `student/` 目录下的 Terraform 配置。
2. 检查当前 state 中的资源地址，以及已经保存的基线证据。
3. 在开始重构之前，确认单体配置执行 `plan` 时不会产生任何变更。
4. 记录以下资源的 Terraform 地址：VPC、两个子网、三个安全组、实例配置文件，以及两个通过 `for_each` 创建的 EC2 实例。
5. 在整个 Lab 过程中，所有基线资源标识符都必须保持不变。

## 任务 2 — 重构为子模块

将单体配置重构为 `student/modules/` 目录下的以下直接子模块：

| 子模块        | 必须管理的资源       |
| ---------- | ------------- |
| `network`  | VPC 和子网       |
| `security` | 安全组和入站规则      |
| `identity` | IAM 角色和实例配置文件 |
| `compute`  | EC2 实例        |

要求：

* 每个子模块都必须包含 `main.tf`、`variables.tf` 和 `outputs.tf`。
* 不得再增加额外的模块嵌套层级。
* 子模块不得直接引用兄弟模块内部的资源。
* 跨模块数据必须通过根模块，并使用明确的输入变量和输出值进行传递。
* 不得硬编码 VPC、子网、安全组、实例配置文件或 EC2 实例的标识符。
* 在最终设计中，共享的 S3 资源和 `random_pet` 必须继续由 shared 根模块管理。

题目提供的模块草稿中故意包含了一些不一致之处。你需要在重构过程中修复这些问题，而不是用一套与原题无关的代码完全替换现有练习。

## 任务 3 — 修复模块依赖关系和接口契约

最终的模块接口必须满足以下全部要求：

* security 模块接收一个字符串类型的 VPC ID。
* network 模块以 map 的形式输出子网 ID，map 的 key 必须与实例定义中使用的逻辑子网 key 保持一致。
* security 模块以 map 的形式输出安全组 ID，map 的 key 必须使用安全组名称。
* identity 模块接收共享命名对象，并生成与基线完全一致的 IAM 角色名称和实例配置文件名称。
* compute 模块接收子网 ID map、安全组 ID map 和实例配置文件名称。
* compute 模块必须使用稳定的字符串 key 选择对应值；不得对 set 使用索引，也不得把 map 当作 list 使用。
* EC2 资源必须继续保持为一个使用 `for_each` 的资源，其 key 为 `gateway` 和 `worker`。

## 任务 4 — 迁移资源地址

更新 Terraform state 中的资源归属，使每个现有对象都由最终目标地址进行管理，同时不得触发资源替换。

最终配置必须覆盖以下迁移场景：

* 将一个普通的单实例资源迁移到子模块中；
* 将两个通过 `count` 创建并带索引的子网实例迁移到 network 模块中；
* 将所有使用字符串 key 的 `for_each` 安全组和 EC2 实例迁移到对应子模块中；
* 安全组规则中的源端和目标端 ID 必须来自模块输出；
* 将 IAM 实例配置文件迁移到 identity 模块中，再由 compute 模块使用。

资源地址迁移完成后，不得再保留任何旧的单体配置资源地址。

## 任务 5 — 拆分根模块并使用远程状态

必须且只能创建两个根模块：

```text
student/
├── infra/
│   ├── shared/
│   └── application/
└── modules/
    ├── network/
    ├── security/
    ├── identity/
    └── compute/
```

### Shared 根模块

`infra/shared` 根模块必须管理：

* `random_pet` 和共享命名逻辑；
* network 模块；
* security 模块；
* 用于存放构件的 S3 Bucket 和对象；
* Terraform backend 使用的 S3 Bucket。

其 S3 backend key 必须严格设置为：

```text
tfpro-sim/lab-01/shared.tfstate
```

### Application 根模块

`infra/application` 根模块必须管理：

* identity 模块；
* compute 模块。

其 S3 backend key 必须严格设置为：

```text
tfpro-sim/lab-01/application.tfstate
```

application 根模块必须通过 `terraform_remote_state` 读取 shared 根模块的输出。只有 application 根模块可以访问远程 state；任何子模块中都不得包含远程 state 数据源或 backend 配置。

## 最终验证

最终提交的证据必须能够证明：

* 不存在同一个资源同时被两个 state 管理的情况；
* application state 中不包含 shared 资源；
* shared state 中不包含 application 资源；
* 两个根模块最终执行 `plan` 时都不会产生任何变更；
* `student/baseline/baseline-resource-ids.json` 中记录的所有标识符都得到了保留。
