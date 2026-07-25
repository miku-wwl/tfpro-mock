# Terraform Professional 模拟实验——Lab 01：模块重构与稳定数据规范化

> 独立练习材料，不是 HashiCorp 官方考试题目。

## 实验背景

一个旧版 LocalStack 环境目前由单一 root module 管理。配置虽然可以运行，但网络、安全、身份、计算、存储、命名和外部数据处理全部混在同一个 state 中。

你的任务是在不替换任何现有基础设施的前提下完成模块重构，并保证外部数据顺序变化不会造成资源地址漂移。

目标用时：70～80 分钟。目标难度：90～95 / 100。

## 实验环境

- Terraform CLI 1.11.x；
- Docker Desktop 和 Docker Compose；
- LocalStack；
- Bash 或 Windows PowerShell。

环境初始化会创建 LocalStack 资源，将基线 state 复制到 student 根目录，并记录基线资源 ID。

## 通用约束

- 保留所有远程资源及其 ID；
- 不要直接编辑 Terraform state JSON；
- 不要使用宽泛的 ignore_changes 掩盖配置漂移；
- 不要硬编码 VPC、subnet、安全组、instance profile、EC2、bucket 或 object ID；
- 子模块不得读取其他子模块的内部资源；
- 只有 root module 可以读取 remote state；
- 最终 for_each key 必须具有业务含义且稳定，不能使用输入行号或列表索引；
- 调整 CSV、JSON、YAML 文件顺序不得导致资源 replacement；
- null 必须保持为 null，不能静默转换为空字符串。

## 输入数据

student/data 中包含 CSV、JSON 和 YAML 三种格式的节点数据。三种格式的原始类型故意不同：

- CSV 中所有值都是字符串，并且可能包含空字符串；
- JSON 中包含数字、布尔值和 null；
- YAML 中包含数字、布尔值、null 和 map；
- 同一个业务 key 可能出现在多个数据源中，优先级为：CSV < JSON < YAML。

需要先把三种数据规范化为统一的对象结构，再传给子模块。

## 任务 1：建立基线

1. 检查当前生效的配置和 state；
2. 确认初始 root plan 不包含 create、update、delete 或 replacement；
3. 记录普通资源、count 实例和 for_each 实例的旧地址；
4. 将关键资源 ID 与 baseline/baseline-resource-ids.json 对比；
5. 保留所有已有基础设施。

## 任务 2：重构为子模块

完成 student/modules 下的四个子模块：

| 模块 | 职责 |
|---|---|
| network | VPC 和 subnet |
| security | 安全组及安全组规则 |
| identity | IAM role 和 instance profile |
| compute | EC2 实例 |

每个子模块必须包含：

~~~text
main.tf
variables.tf
outputs.tf
~~~

要求：

- network 和 compute 的输入使用带类型约束的 object map；
- root module 负责把解码后的 list 转换为稳定的 map；
- 至少一个子模块 object 属性必须是 optional。

## 任务 3：修复数据和模块依赖

修复重构脚手架中的语义问题，使其满足：

- security module 通过 root module 的值接收 VPC ID；
- compute module 通过 map 接收 subnet ID；
- compute module 通过 map 接收 security group ID；
- compute module 接收 instance profile name；
- shared naming 传给 identity 和 compute module；
- 所有模块输出都通过已声明的 output contract 使用；
- 重复业务 key 按 CSV < JSON < YAML 的优先级处理；
- 条件表达式的两个分支类型兼容；
- 不通过数字索引访问 set；
- 使用已声明的 object 属性名；
- null description 保持为 null；
- 至少一个 output 能按照实际资源 key 重建 map。

应合理使用 flatten、merge、distinct、toset、lookup 等 collection function，避免复制式实现。

## 任务 4：迁移资源地址

在不重建远程资源的前提下，将旧 state 地址迁移到最终 module 地址。最终地址必须覆盖：

- 普通资源地址；
- 从旧 count 地址迁移到稳定业务 key；
- 已有的 for_each 地址；
- 转移到另一个 root state 的资源。

最终 plan 不得残留旧地址，也不得因为重构本身产生 create、delete 或 replacement。

## 任务 5：拆分 root module 和 state

完成两个独立的 root module：

~~~text
student/infra/shared
student/infra/application
~~~

S3 backend key 必须精确为：

~~~text
tfpro-sim/lab-01/shared.tfstate
tfpro-sim/lab-01/application.tfstate
~~~

shared root 管理 network、security、shared naming、artifact storage 和 LocalStack state bucket。

application root 管理 identity 和 compute。

application root 必须通过 terraform_remote_state 获取 shared 输出。只有 application root 可以访问 remote state，子模块不得直接访问。

## 完成标准

- shared root plan：0 to add, 0 to change, 0 to destroy；
- application root plan：0 to add, 0 to change, 0 to destroy；
- 关键资源 ID 与 baseline 一致；
- 不残留旧的单体资源地址；
- 调整三种输入文件顺序后，不产生 create、delete 或 replacement；
- outputs 正确暴露规范化对象 map、按资源 key 索引的 inventory，以及保持为 null 的 description。

