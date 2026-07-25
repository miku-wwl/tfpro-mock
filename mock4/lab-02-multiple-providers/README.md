# Lab 02 —— Provider 矩阵恢复

> Terraform Professional 风格练习题，非 HashiCorp 官方考试题目。

## 场景

平台团队将同一套 AWS 资源交给三个不同的操作身份管理。一次 provider 升级和一次未完成的资源迁移，使当前配置处于不安全状态。你需要在保留 LocalStack 资源和 Terraform state 的前提下，修复配置。

目标用时：50～60 分钟；难度：高级。

LocalStack 只用于可重复练习，可以验证 profile 加载、provider alias、模块 provider 映射、state 地址迁移、生命周期设置和 plan 行为；它不能证明真实 AWS IAM 权限边界。

## 工具要求

- Terraform CLI 1.11.x
- Docker Desktop 或 Docker Engine
- Docker Compose v2
- Bash 或 PowerShell
- Python 3（用于顺序打乱测试）

## 初始环境

环境初始化会创建：

- 三个操作角色；
- 一个 launch template 和 Auto Scaling Group；
- 一个审计 IAM user；
- 一个 S3 bucket；
- 内容严格为 `ORIGINAL-CONTENT` 的 `artifact.txt`；
- 该对象的旧 state 地址；
- 按 profile purpose 设置 key 的 `terraform_data` 地址。

不要直接编辑 `terraform.tfstate` JSON，也不要删除或重新创建 S3 对象。

## 任务 1：规范化外部 provider 目录

修复 `student/locals.tf` 中的表达式。

目录数据来自 CSV、JSON 和 YAML，三种格式的原始值有意不同：CSV 主要是字符串并包含空字符串，JSON/YAML 包含数字、布尔值和 null；其中存在重复逻辑 key、与 AWS profile 名称不同的 map key，以及分支类型不兼容的条件表达式。

要求：

- 使用语义 key，不能使用输入行号；
- 明确合并重复片段，不能静默丢弃数据；
- 保留 null，直到明确应用默认值；
- 统一布尔值和数字类型；
- 将 module targets 规范化为去重且稳定的集合；
- 调整输入顺序时，资源地址不能变化。

## 任务 2：构建 AWS 共享配置和凭据

创建：

- `student/.aws/config`
- `student/.aws/credentials`

config 中只能包含以下三个 role profile，不能有 `default`：

- `compute-operator`
- `identity-operator`
- `readonly-auditor`

三个 profile 都使用 `us-east-1`、正确的 role ARN、source profile 和输出格式。credentials 只放 LocalStack 测试凭据，不能放真实 AWS 凭据。

starter 中存在路径错误、无效 default profile 和错误名称；创建正确文件后，应删除或停止使用这些干扰文件。

## 任务 3：修复 provider 与模块映射

root module 必须静态声明三个 alias：

- `aws.compute`
- `aws.identity`
- `aws.readonly`

要求：

- compute module 只能使用 `aws.compute`；
- identity module 只能使用 `aws.identity`；
- storage module 必须显式接收指定 provider；
- `data.aws_caller_identity.current` 必须使用 `aws.readonly`；
- 每个 module 调用都要显式传入 `providers` map；
- 子模块通过 `configuration_aliases` 声明所需 alias；
- 子模块不能创建不可控的默认 AWS provider；
- provider alias 不能使用动态 `for_each` 生成。

## 任务 4：安全升级 AWS provider

修复不兼容的 provider 约束和 lock 文件：

- 使用明确且兼容的版本范围；
- 不能删除版本约束；
- 不能使用无界的 latest 版本；
- 通过 Terraform 更新 lock 文件；
- `terraform init` 必须无 provider 版本冲突地完成。

## 任务 5：迁移已有对象且不得替换

远程对象已经存在。starter 同时包含 legacy resource type 和新的 resource type，并且内容存在细微差异。

最终必须满足：

- 只有 `aws_s3_object.artifact` 管理该对象；
- legacy resource type 和旧 state 地址消失；
- bucket 和 key 不变；
- 内容严格保持为 `ORIGINAL-CONTENT`；
- 不能删除、重新创建或覆盖远程对象；
- 最终 plan 不能包含 create、delete 或 replace。

选择一种 Terraform 支持的 state 映射方式完成迁移。题目不会直接给出命令、import ID 或完整答案。

## 任务 6：保留远程计算容量

现有 Auto Scaling Group 的远程 desired capacity 是 `1`。修复后的配置必须声明 `desired_capacity = 2`，但 Terraform 不能计划修改这个远程属性。

要求：

- 只忽略精确的 desired capacity 属性；
- 不能使用 `ignore_changes = all`；
- 不能忽略整个资源；
- 不能从 state 中移除资源；
- 其他漂移仍必须可见。

## 任务 7：使用 shuffle test 验证 key 稳定性

得到 clean plan 后，运行：

```powershell
./scripts/shuffle-test.ps1 -Target student
```

或：

```bash
./scripts/shuffle-test.sh student
```

脚本会确定性地打乱 CSV、JSON、YAML 记录，重新生成 plan，并在完成后恢复原文件。输入顺序变化不能产生 create、delete 或 replace，也不能改变持久资源地址。

## 完成标准

- profile 数据已规范化；
- root 只有三个固定 AWS alias；
- module provider 映射显式且正确；
- 子模块声明了 `configuration_aliases`；
- provider lock 已更新；
- 只有新的 S3 object 地址管理对象；
- 对象内容保持不变；
- desired capacity 仅按要求忽略；
- 最终 plan 为 `0 to add, 0 to change, 0 to destroy`；
- shuffle test 不产生 create、delete 或 replace。

完成尝试后，再使用独立 solution package 中的 `VALIDATION.md` 进行核验。
