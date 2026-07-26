# 实验 02：分层的 AWS Provider 操作

> 独立的 Terraform Professional 练习实验，不代表官方考试题目。

## 场景

Northstar Media 正在为区域批处理平台拆分运维职责。现有 Terraform 状态是在身份模型、provider 归属规则和对象资源规范更新之前生成的。

远端环境已经运行。你的任务是在不影响已保存的发布制品、也不改变当前工作节点数量的前提下，修复配置和状态映射。

**建议用时：**50 分钟
**Terraform CLI：**1.11.x
**执行环境：**`us-east-1` 中的 LocalStack

## 环境状态

初始化脚本会准备三个可供 LocalStack assume 的 IAM 角色、一个 launch template、一个 Auto Scaling Group（远端 desired capacity 为 `1`）、一个受管 IAM 角色及内联策略、一个包含精确内容 `ORIGINAL-CONTENT` 的 `artifact.txt` 存储桶对象，以及记录为 `aws_s3_bucket_object.legacy_artifact` 的初始状态。`.exam/` 中还包含非答案基线证据。

请根据使用的 shell 运行对应的 Bash 或 PowerShell 脚本。reset 脚本会丢弃所有候选修改并重建初始环境。

## 完成条件

完成以下五项任务。最终 plan 不得包含创建、更新、删除或替换操作。

### 任务 1：重建共享身份文件

创建：

- `student/.aws/config`
- `student/.aws/credentials`

配置文件必须恰好包含以下角色 profile，且不得包含 `default`：`compute-operator`、`identity-operator`、`readonly-auditor`。每个 profile 必须使用 `us-east-1`、JSON 输出、对应角色 ARN 和不同的 `source_profile`。

凭据文件必须恰好包含以下仅供 LocalStack 使用的 source profile：`compute-origin`、`identity-origin`、`audit-origin`。

不得在本实验任何位置放置长期凭据或真实 AWS 凭据。

### 任务 2：强制 provider 归属

根模块必须暴露以下 aliased AWS provider：

- `aws.compute`
- `aws.identity`
- `aws.readonly`

归属规则如下：compute 模块使用 `aws.compute`；identity 模块使用 `aws.identity`；storage 模块使用 `aws.identity`；`data.aws_caller_identity.current` 使用 `aws.readonly`。每个模块都必须由根模块显式接收 provider；子模块必须声明接受的 alias，不得创建独立配置；任何资源或数据源都不得依赖默认 provider 的隐式继承。

### 任务 3：安全升级 AWS provider

将过时的精确版本锁定替换为明确的兼容范围，该范围必须允许 `5.80.0` 及以上版本、排除 `6.0.0` 及更高版本，且不能是无上限约束或 `latest`。刷新依赖锁文件，使其与约束一致；初始化必须无版本冲突。

### 任务 4：在不修改远端的情况下处理对象

已有 `artifact.txt` 最终必须使用地址 `aws_s3_object.artifact`，并满足：

- `aws_s3_bucket_object.legacy_artifact` 同时从配置和状态中移除；
- 存储桶和对象 key 不变；
- 内容仍精确为 `ORIGINAL-CONTENT`，且末尾没有换行；
- 对象没有被删除、重新创建或覆盖；
- 不得直接编辑 Terraform 状态 JSON。

### 任务 5：保留外部控制的容量

配置继续声明 desired capacity 为 `2`，远端 Auto Scaling Group 保持为 `1`。Terraform 只能忽略 desired-capacity 属性的漂移，仍须检测其他受管属性变化，且资源必须继续保留在状态中。

## 提交证据

完成前确认：profile 和凭据文件只包含允许的段；所有 AWS 使用方都明确指定 provider；锁文件与约束一致；旧对象地址已消失且目标地址存在；对象身份和内容与基线一致；远端 desired capacity 仍为 `1`；最终 plan 干净。
