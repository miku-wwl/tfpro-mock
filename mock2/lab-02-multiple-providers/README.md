# Lab 02：多 Provider 与安全 State 迁移

> 这是一份独立的 Terraform Professional 模拟练习材料，并非 HashiCorp 官方考试题目。

## 场景

平台团队接手了一套由 LocalStack 驱动的 AWS Terraform 配置。此前进行过不完整的 provider 升级，导致 Terraform 配置、provider alias、依赖锁文件、模块传参和 state 地址之间不再一致。

你的目标是在**不销毁、不替换、不重新创建，也不覆盖**任何已预置远程对象的前提下修复该项目。完成后的主配置和 audit 配置都必须产生无变更的 plan。

**建议用时：** 50–60 分钟

**难度：** 90–95 / 100

## 安全要求

- 只能在 `student/` 目录内操作。
- 不得直接编辑 Terraform state JSON。
- 不得连接真实 AWS 账户；题目提供的文件只使用 LocalStack 测试凭证。
- 执行 `apply` 前必须先检查 plan。
- 不得销毁或替换任何已预置资源。
- 必须保留 `artifact.txt` 的 bucket、key、内容字节、hash 以及远程身份不变。
- 最终 main state 与 audit state 不得同时管理同一个远程对象。

## 开始与重置

在 Lab 根目录执行：

```bash
./scripts/setup.sh
```

Windows PowerShell：

```powershell
./scripts/setup.ps1
```

初始化脚本会创建可丢弃的 LocalStack 环境、预置旧拓扑、将初始 state 写入 `student/`，并在 `student/.baseline/` 下记录验证证据。

如需恢复到最初的练习状态：

```bash
./scripts/reset.sh
```

## 任务 1：修复共享 AWS 文件

创建以下文件：

- `student/.aws/config`
- `student/.aws/credentials`

config 文件必须且只能包含以下三个角色 profile：

- `compute-operator`
- `identity-operator`
- `readonly-auditor`

要求：

- 每个角色 profile 都使用 `us-east-1` 区域和 JSON 输出。
- 每个角色 profile 都必须包含适当的 `role_arn` 和 `source_profile`。
- config 文件中不得出现 `default` profile。
- credentials 文件可以包含一个供上述三个角色 profile 共用的 LocalStack source profile。
- 不得写入真实凭证。

## 任务 2：修复 provider alias 与模块传参

根模块必须准确声明以下 AWS alias：

- `aws.compute`
- `aws.identity`
- `aws.readonly`

要求：

- compute 模块使用 `aws.compute`。
- identity 模块使用 `aws.identity`。
- storage 模块及其嵌套的 catalog 模块都必须显式接收 provider 映射。
- `data.aws_caller_identity.current` 使用 `aws.readonly`。
- 每个子模块都必须声明自己可接收的 alias。
- 子模块不得悄悄创建不受控制的默认 AWS provider。
- 仍指向旧 provider 配置的已有 state 条目，必须与修复后的 provider 布局一致。

## 任务 3：安全升级 AWS Provider

修复所有 provider requirement，使根模块与子模块都接受同一个明确且兼容的 AWS provider `5.82.x` 版本。

要求：

- 不得使用 `latest`。
- 不得删除所有版本约束。
- 必须用正常 Terraform 命令重新生成依赖锁文件。
- 在改动任何远程对象前，确认选定的 provider 与现有 state 兼容。

## 任务 4：迁移已有 S3 对象

远程对象已存在，key 为 `artifact.txt`，内容精确如下：

```text
ORIGINAL-CONTENT
```

其旧 state 地址为：

```text
aws_s3_bucket_object.legacy_artifact
```

要求迁移至：

```text
aws_s3_object.artifact
```

要求：

- 配置和 state 中都不再保留已废弃的 resource type。
- 最终不得同时管理旧地址与新地址。
- bucket 与 key 必须保持不变。
- 对象内容字节、hash、ETag 或等效身份凭证必须保持不变。
- 不得删除、重新创建、替换或覆盖该对象。
- 最终 plan 不得包含 create、update、delete 或 replace 操作。

## 任务 5：保留期望容量 drift

已预置的 Auto Scaling Group 远程 `desired_capacity` 为 `1`。修复后的配置必须声明为 `2`，但远程值仍保持 `1`。

要求：

- 只能忽略 `desired_capacity`。
- 不得忽略整个资源或其他无关属性。
- 不得将 Auto Scaling Group 从 state 中移除。
- 最终 plan 不得更新远程的 desired capacity。

## 任务 6：无资源扰动地完成地址重构

将旧 state 与目标模块结构对应起来。

目标映射：

| 旧地址 | 必须迁移到的最终地址 |
|---|---|
| `aws_launch_template.capacity_template` | `module.compute.aws_launch_template.capacity_template` |
| `aws_autoscaling_group.capacity_group` | `module.compute.aws_autoscaling_group.capacity_group` |
| `aws_iam_user.pipeline_identity` | `module.identity.aws_iam_user.pipeline_identity` |
| `aws_iam_user.service_accounts[0]` | `module.identity.aws_iam_user.service_accounts["api-gateway"]` |
| `aws_iam_user.service_accounts[1]` | `module.identity.aws_iam_user.service_accounts["batch-worker-prod"]` |
| `aws_s3_object.catalog_manifest` | `module.storage.module.catalog.aws_s3_object.manifest` |

额外要求：

- 两个 service account 必须使用稳定的 `for_each` key，且不得依赖输入列表顺序。
- 最终 service account output 必须是以稳定 key 为键的 map，不得是位置相关的 list。
- `aws_s3_bucket.audit_archive` 必须转移到 `student/audit-state/` 下的独立配置。
- main state 与 audit state 不得同时管理 audit bucket。
- 任何地址映射都不得造成地址 churn、资源替换或远程资源重新创建。

## 完成证据

在宣布完成前，必须记录或检查以下内容：

1. 两个 state 的 `terraform state list`。
2. Provider requirement 与 lock file 中实际选择的版本。
3. main state 的最终 saved plan。
4. audit state 的最终 saved plan。
5. S3 对象在迁移前后的内容、hash、ETag 或等效身份凭证。
6. Auto Scaling Group 在迁移前后的 desired capacity。
7. 确认两个最终 plan 均为 `0 to add, 0 to change, 0 to destroy`。

完成修改后，可使用 `scripts/validate.sh` 或 `scripts/validate.ps1` 做非评分性质的结构验证。
