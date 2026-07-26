# 实验 02：多 Provider、配置文件与零重建迁移

> 独立的 Terraform Professional 练习材料，不代表 HashiCorp 官方考试题目。

## 场景

平台团队将 AWS 操作拆分给计算、身份和审计三类角色。当前项目表面上可以运行，但可能在悄悄使用错误的凭据、隐式 provider、过时的依赖选择，并且会破坏性地迁移 S3 对象。请在不修改已有远端对象的前提下修复这些问题。

**建议用时：**50–60 分钟
**目标难度：**90–95 / 100
**Terraform CLI：**1.11.x
**环境：**Docker Desktop、Docker Compose、LocalStack、Bash 或 PowerShell

LocalStack 会检查文件加载、alias、模块 provider 映射、状态地址、S3 对象保留、生命周期行为和 plan 输出。它不能证明真实 AWS IAM 授权边界；相关限制会在 solution review 中说明。

## 开始与重置

在实验根目录执行：

```bash
./scripts/setup.sh
```

或：

```powershell
./scripts/setup.ps1
```

初始化脚本会创建基础环境并准备实验状态。只能在 `student/` 中工作。若要放弃修改并重新生成初始环境，请使用对应的 reset 脚本。

不得在项目的任何位置放置真实 AWS 凭据。名为 `test` 的值仅供 LocalStack 使用。

## 状态与后端约定

候选根模块是 `student/`。唯一的后端必须是 `student/versions.tf` 根层的 `backend "s3"` block。

- 后端存储桶：`tfpro-lab02-state`
- 后端 key：`set-05/lab-02/terraform.tfstate`
- 区域：`us-east-1`
- LocalStack S3 endpoint：`http://localhost:4566`

不得在任何子模块中添加 backend block，不得将本地状态作为最终状态，也不得修改后端 key。

## 任务 1：修复共享 AWS 文件

必须创建且只能创建以下文件：

- `student/.aws/config`
- `student/.aws/credentials`

`student/.aws/config` 必须恰好包含三个角色 profile，且不得包含 `[default]` 段：

- `compute-operator`
- `identity-operator`
- `readonly-auditor`

每个角色 profile 都必须使用 `region = us-east-1`、`output = json`、对应的 LocalStack 角色 ARN，以及 `source_profile = localstack-seed`。角色名称可从 bootstrap 输出中发现，也列在 `bootstrap/foundation/outputs.tf` 中。

`student/.aws/credentials` 必须恰好包含一个名为 `localstack-seed` 的 source profile，并使用仅供 LocalStack 使用的静态值。不得将 access key 写入任何 Terraform provider block。依赖环境变量或默认凭据虽然可能运行，但不符合本任务要求。

正确文件创建后，删除误导性的 profile 文件。最终 provider 配置必须引用上述两个精确路径。

## 任务 2：强制使用指定的 provider 身份和模块边界

`student/providers.tf` 中必须恰好包含三个 `provider "aws"` block，且三个都必须使用 alias；不允许存在最终的未命名/默认 AWS provider。

| 根 provider | 必需 profile | 授权用途 |
|---|---|---|
| `aws.compute` | `compute-operator` | compute 模块、storage 模块和根 S3 对象 |
| `aws.identity` | `identity-operator` | 仅 identity 模块 |
| `aws.readonly` | `readonly-auditor` | 仅 `data.aws_caller_identity.current` |

根模块必须在每个 module block 的 `providers` map 中显式传入 provider。每个子模块都必须通过 `configuration_aliases` 声明所需的 alias；子模块不得创建自己的 provider 配置。

最终必须保留下列资源类型、文件位置、模块边界和 resource block 数量约定：

- `student/modules/compute/main.tf`：恰好 1 个 `aws_launch_template` block 和 1 个 `aws_autoscaling_group` block；
- `student/modules/identity/main.tf`：恰好 1 个 `aws_iam_user` block；
- `student/modules/storage/main.tf`：恰好 1 个 `aws_s3_bucket` block；
- `student/main.tf`：恰好 3 个 module block、1 个 `aws_caller_identity` data block，以及 1 个最终 S3 对象资源 block。

即使两模块设计能够生成相同基础设施，也不得合并这些模块。

## 任务 3：升级并锁定 AWS provider

设置明确且兼容的 AWS provider 约束，选择 `5.100.x` 发布线。不得使用 `latest`、无约束 provider 或 `6.x` 版本。

更新 `.terraform.lock.hcl`，使其与最终约束一致。`terraform init -upgrade` 必须在不发生版本选择冲突的情况下完成。根模块和每个子模块都必须使用 `hashicorp/aws` 作为 provider source。

## 任务 4：保留并迁移 `artifact.txt`

已有对象的固定属性如下：

- 存储桶：`tfpro-lab02-artifacts`
- key：`artifact.txt`
- 内容：`ORIGINAL-CONTENT`
- 初始状态地址：`aws_s3_bucket_object.legacy_artifact`
- 最终状态地址：`aws_s3_object.artifact`

最终代码必须在 `student/main.tf` 中恰好包含一个名为 `artifact` 的 `aws_s3_object` 资源 block。`student/` 下不得残留任何 `aws_s3_bucket_object` block。

必须保留远端存储桶、对象 key、内容和对象身份。迁移不得执行远端删除、替换或重新上传。仅修改资源类型并不足够，因为这会产生创建/删除 plan。不得直接编辑状态 JSON。

README 不会提供迁移命令或导入标识符。请自行确定安全的状态操作，并使用 `bootstrap/baseline/` 中生成的基线文件证明对象得到保留。

## 任务 5：精确接受 desired capacity 漂移

最终 `student/modules/compute/main.tf` 中的 `aws_autoscaling_group` 必须声明 `desired_capacity = 2`，而已有远端 Auto Scaling Group 仍保持为 `1`。

在该资源上使用生命周期规则，仅忽略 `desired_capacity`。`ignore_changes = all`、忽略无关 block、从状态中移除资源，或将配置值改回 `1`，均不符合要求。

## 必需的根输出

在 `student/outputs.tf` 中定义且只能定义以下根输出。每个输出都必须计算为 Terraform `string`，并且必须来自资源、模块输出或只读数据源，而不能是硬编码文本：

- `compute_group_name`
- `identity_user_arn`
- `artifact_object_key`
- `readonly_account_id`

看似正确但硬编码的输出不得分。

## 完成标准

完成迁移和配置修复后：

1. `terraform fmt -check -recursive` 通过；
2. `terraform init -upgrade` 使用指定后端 key 成功；
3. `terraform validate` 成功；
4. `terraform state list` 包含 `aws_s3_object.artifact`，且不包含 `aws_s3_bucket_object.legacy_artifact`；
5. 保存的 plan 报告 **0 to add, 0 to change, 0 to destroy**；
6. 基线和最终的 S3 key、内容 hash 及 ETag/身份字段一致；
7. 远端 desired capacity 仍为 `1`，而配置声明为 `2`。

可使用 `scripts/validate.sh` 或 `scripts/validate.ps1` 执行非评分结构检查。该脚本不会对实现进行评分。

## 容易失分的做法

即使 Terraform 能够运行，以下实现也不符合要求：

- 使用默认/环境凭据而不是指定 profile；
- 在 provider block 中嵌入 test 凭据或真实 access key；
- 依赖隐式 provider 继承，而不是显式模块映射；
- 替换旧 S3 对象，而不是重新映射其状态；
- 使用宽泛的生命周期忽略规则；
- 保留本地后端或修改要求的 key；
- 使用替代资源类型或硬编码输出。
