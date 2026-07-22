# Terraform Professional 模拟练习 — Lab 01：安全重构模块与 State

> 本练习为独立的学习材料，并非 HashiCorp 官方考试题目。

## 场景

一个平台团队维护着一套可正常运行、但耦合紧密的 Terraform 根模块。所有基础设施都已存在于目标账户中，当前本地 state 与旧配置完全一致。团队希望将其拆分成两个可独立运维的根模块，同时不得改变任何远程对象。

你有 **70–80 分钟** 完成练习。对于任何已有对象，只要 plan 提议 create、delete 或 replacement，均视为迁移失败。

## 环境

- Terraform CLI 1.11.x
- 已安装 Docker Compose 的 Docker Desktop
- LocalStack
- Bash 或 Windows PowerShell

开始前请运行提供的初始化脚本。该脚本会创建已有资源、将匹配的 state 复制到 `student/`，并记录真实的基线 ID。不得在本 Lab 的任何位置写入真实 AWS 凭证。

## 初始状态

- `student/combined.tf` 是当前生效且有效的单体配置。
- `student/infra/` 和 `student/modules/` 中包含一份未完成的重构草稿。该草稿尚未接入当前根模块，并且刻意包含若干依赖关系和类型缺陷。
- 所有受管理对象都受到保护，不能被销毁。
- 在修改前，当前生效的根模块必须产生无变更的 plan。

## 最终目录结构

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

只要所有权边界清晰，允许在上述模块内部继续嵌套实现。

## 任务 1 — 建立基线

1. 检查当前生效的配置和 state。
2. 确认初始 plan 不包含任何基础设施变更。
3. 将所有普通、带索引、带 key、可迁移至 module 的资源地址，以及嵌套 module 的资源地址，记录到 `student/ADDRESS-WORKSHEET.md`。
4. 记录初始化脚本生成的基线 ID。
5. 如果任何已有对象被计划创建、删除或替换，不得继续后续任务。

## 任务 2 — 重构为子模块

创建并接入以下四个必需的子模块：

- `network`：管理 VPC 和子网。
- `security`：管理 security group 和 ingress rule。
- `identity`：管理 IAM role 和 instance profile。
- `compute`：管理 EC2 instance。

每个必需模块都必须包含 `main.tf`、`variables.tf` 和 `outputs.tf`。子模块不得直接访问兄弟模块的内部资源；所有跨模块值都必须通过根模块的输入与输出传递。不得硬编码远程 ID。

最终的 shared 根模块必须以 `shared` 作为模块名称调用 network 模块；最终的 application 根模块必须以 `application` 作为模块名称调用 identity 模块。

## 任务 3 — 修复依赖关系与模块契约

在保留现有远程配置的前提下，修复草稿中的所有缺陷。

最终设计必须满足以下所有要求：

- security 模块通过输入变量接收 VPC ID。
- compute 模块接收一个**以网段名称为 key 的 map**形式的 subnet ID。
- compute 模块以 map 形式接收 security group ID。
- compute 模块通过输入变量接收 instance profile 名称。
- identity 模块通过输入变量接收 shared naming token。
- 至少有一个模块通过根模块消费另一个模块输出的 map。
- 最终 subnet 集合必须以稳定的网段名称作为 key，且不依赖原始 list 的顺序。
- 原先有序的 subnet output 必须替换为以 key 为基础的 map 契约。

## 任务 4 — 在修改地址时保留资源身份

将已有对象迁移至其最终所有者，且不得重新创建资源。

最终 state 结构必须覆盖：

- 一个普通资源地址；
- 一个从索引地址转换为稳定 key 实例的资源地址；
- 包含连字符或复合字符串的带 key 资源实例；
- 一个由 `module.shared` 持有的根资源；
- 一个由 `module.application` 持有的根资源；
- 至少一个嵌套 module 地址。

README 只说明最终结果；请自行选择合适的 Terraform state 与配置机制。不得直接编辑 state JSON。

## 任务 5 — 拆分根模块与 State

创建两个彼此独立的根模块：

### Shared 根模块

路径：`student/infra/shared`

管理以下内容：

- 共享命名；
- network；
- security；
- artifact bucket 和 retained object；
- remote-state bucket。

其 S3 backend key 必须精确为：

```text
tfpro-sim/lab-01/shared.tfstate
```

### Application 根模块

路径：`student/infra/application`

管理以下内容：

- identity；
- compute。

其 S3 backend key 必须精确为：

```text
tfpro-sim/lab-01/application.tfstate
```

application 根模块必须通过 `terraform_remote_state` 读取 shared 模块输出的契约。只有根模块可以访问 remote state，子模块不得访问。

最终每个资源只能由一个 state 管理。shared 资源不得继续留在 application state 中，application 资源也不得继续留在 shared state 中。

## 完成条件

- 两个最终根模块均可成功初始化。
- 两个最终根模块均可成功通过验证。
- 两个最终 plan 均显示 **0 to add, 0 to change, 0 to destroy**。
- 所有已有资源的 ID 均未发生变化。
- 不保留任何旧资源地址。
- 不得使用宽泛的 `ignore_changes` 规则掩盖 drift。
- 提交内容中不得包含真实凭证或 provider 二进制文件。
