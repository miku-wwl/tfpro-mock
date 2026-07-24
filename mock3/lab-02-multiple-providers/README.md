# Lab 02：多 Provider 与身份边界

> 这是 Terraform Professional 练习环境，不是官方考试题目。

## 场景

平台团队接手了一个部分迁移的 Terraform 项目。LocalStack 中的远程资源已经存在，但当前配置故意包含多处问题：AWS 共享配置路径错误、profile 名称错误、provider 映射错误、provider 版本约束不一致、state 地址过期，以及不正确的生命周期设置。

你的目标是在不重新创建既有 S3 对象、且不改变线上 Auto Scaling Group 容量的前提下，修复整个项目。

- 建议用时：50～60 分钟
- 难度：90～95 / 100
- Terraform CLI：1.11.x
- 工作目录：`student/`

## 安全规则

- 只能使用本练习提供的 LocalStack 凭据；
- 不要把真实 AWS 凭据写入仓库；
- 不要直接编辑 `terraform.tfstate` JSON；
- 每次 apply 前都必须检查 plan；
- 如果 provider 身份、profile、模块映射或 state 地址不正确，不要因为 plan 看起来干净就继续；
- 不得删除、重建或覆盖 `artifact.txt`。

## 环境

本环境已经准备好。进入以下目录开始练习：

```powershell
Set-Location student
```

初始化资源包括：

- 三个 IAM role，分别代表 compute、identity 和 readonly 边界；
- 一个 VPC、两个子网和一个 Launch Template；
- 一个当前 `desired_capacity = 1` 的 Auto Scaling Group；
- identity 模块管理的 IAM policy；
- 一个包含 `artifact.txt` 的 S3 bucket，内容精确为 `ORIGINAL-CONTENT`；
- state 中已有旧地址 `aws_s3_bucket_object.legacy_artifact`。

## 任务 1：修复 AWS 共享配置和凭据

在以下位置创建文件：

```text
student/.aws/config
student/.aws/credentials
```

`config` 中只能有以下三个目标 profile：

- `compute-operator`
- `identity-operator`
- `readonly-auditor`

要求：

- 不要定义 `default` profile；
- 三个 profile 都使用 `us-east-1`；
- 设置 `output = json`；
- 使用正确的 `role_arn` 和 `source_profile`；
- LocalStack 源凭据放在 credentials 文件中，不要写入 Terraform provider block；
- 移除或停止使用误导性的 starter 文件和错误路径。

## 任务 2：修复 Provider 与模块身份映射

root 模块必须定义以下三个 alias：

```text
aws.compute
aws.identity
aws.readonly
```

要求：

- compute 模块只能使用 `aws.compute`；
- identity 模块只能使用 `aws.identity`；
- storage 模块必须显式接收 provider 映射；
- `data.aws_caller_identity.current` 必须使用 `aws.readonly`；
- 每个 module 调用都必须显式提供 `providers` map；
- 子模块必须使用 `configuration_aliases` 声明接收的 alias；
- 子模块不得创建不可控的默认 AWS provider；
- 删除 root 默认 AWS provider，不要把它当作快捷方式。

## 任务 3：升级 AWS Provider 并修复 lock 文件

starter 的 provider 约束与 lock 文件故意不一致。

要求：

- 使用清晰且有边界的 AWS provider 版本约束；
- 不得使用 `latest`，也不得删除所有版本约束；
- 保留要求的 Terraform CLI 版本范围；
- 使用 Terraform 刷新 `.terraform.lock.hcl`，不得手工编造 checksum；
- `terraform init` 不得再出现版本选择冲突。

## 任务 4：迁移已有 S3 对象，避免替换

对象当前地址为：

```text
aws_s3_bucket_object.legacy_artifact
```

最终地址必须为：

```text
aws_s3_object.artifact
```

要求：

- 代码和 state 中都不能保留旧资源类型；
- bucket 和 key 必须保持不变；
- 内容必须精确保持为 `ORIGINAL-CONTENT`；
- 不得删除、重建、替换或覆盖对象；
- 必须使用 Terraform state/import 机制，不得直接编辑 state JSON；
- 对照本地基线证据中的 hash 或 ETag 检查对象身份；
- 最终 plan 不得包含创建、更新、删除或替换。

## 任务 5：精确处理 desired capacity 漂移

compute 模块配置必须声明：

```hcl
desired_capacity = 2
```

但远程 Auto Scaling Group 必须继续保持容量 `1`。

要求：

- 只能忽略 `desired_capacity`；
- 不得使用 `ignore_changes = all`；
- 不得忽略整个资源；
- 不得把资源从 state 中移除；
- 不得通过修改 `min_size` 或 `max_size` 隐藏问题；
- 最终 plan 不得更新远程容量。

## 完成检查

```powershell
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform state list
terraform state show aws_s3_object.artifact
terraform plan -out=final.tfplan
terraform show -no-color final.tfplan
```

还应确认：

- `.aws/config` 中只有三个目标 profile；
- source profile 和 role ARN 正确；
- 三个 provider alias 都存在；
- module provider 映射和 `configuration_aliases` 完全匹配；
- 旧 S3 state 地址消失，新地址存在；
- 对象内容与基线一致；
- Auto Scaling Group 仍为容量 `1`；
- 最终 plan 为 `0 to add, 0 to change, 0 to destroy`。
