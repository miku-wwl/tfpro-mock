# Lab 04：State 恢复与零重建迁移

## 实验背景

本实验模拟一次被中断的 Terraform state 迁移。当前环境中存在错误的 backend、旧资源地址、未被当前 state 管理的远程资源，以及一个需要停止管理但不能删除的 S3 对象。

最终目标是：在不销毁或重新创建任何已有资源的前提下，修复配置和 state，并得到：

```text
0 to add, 0 to change, 0 to destroy
```

## 安全要求

- 不要直接编辑 `terraform.tfstate` JSON。
- 不要使用 `ignore_changes = all` 掩盖问题。
- 不得销毁或重建已有 bucket、IAM user、安全组、安全组规则或 S3 object。
- 每次 apply 前先检查 plan，确认没有 destroy、create 或 replacement。
- 只使用 Terraform 命令完成 state 的迁移、导入和移除。

## 任务 1：修复 backend 并迁移 state

将现有本地 state 迁移到正确的 LocalStack S3 backend。最终必须满足：

- backend 类型为 `s3`；
- key 精确为 `tfpro-sim/lab-04/terraform.tfstate`；
- region 为 `us-east-1`；
- S3 endpoint 为 `http://localhost:4566`；
- 迁移时保留现有 state，不得丢弃；
- 完成后不得继续使用本地 backend；
- `.terraform.lock.hcl` 必须有效并与当前配置一致。

backend 配置与 AWS provider alias 是两个不同概念，不要混淆。

## 任务 2：接管已有资源

通过修复配置、迁移 state 地址和必要的 import，使主 state 最终包含以下精确地址：

```text
aws_s3_bucket.assets
aws_s3_bucket.logs
aws_iam_user.members["alpha"]
aws_iam_user.members["beta"]
aws_iam_user.members["gamma"]
aws_security_group.application
aws_vpc_security_group_ingress_rule.rules["http"]
aws_vpc_security_group_ingress_rule.rules["admin"]
```

provider 归属必须正确：

- S3 bucket 和 object 使用 `aws.storage`；
- IAM user 使用 `aws.identity`；
- 安全组和规则使用 `aws.network`；
- 只读 caller identity 使用 `aws.readonly`。

import ID 应根据基线记录和只读查询确定。导入或迁移后，同一个远程资源不得由两个地址同时管理。

## 任务 3：恢复资源地址

在不删除或重新创建真实资源的前提下，恢复最终模型：

- `aws_s3_bucket.primary` 不存在；
- `aws_iam_user.alpha`、`beta`、`gamma` 不存在；
- `aws_vpc_security_group_ingress_rule.legacy_http` 不存在；
- `terraform_data.stale_record` 不存在；
- IAM `for_each` key 必须精确为 `alpha`、`beta`、`gamma`；
- 同一个远程资源不得同时由两个地址管理；
- 地址迁移不得产生 destroy/create 或 replacement。

## 任务 4：停止管理 retained.txt

`retained.txt` 必须继续存在于远程 bucket 中，但不再由 Terraform 管理。完成后必须满足：

- 配置中没有 `retained.txt` 资源块；
- state 中不存在对应地址；
- 远程对象仍存在，内容精确为 `KEEP-ME`；
- 对象没有被删除、替换或重新导入。

删除资源配置前，必须先使用 `terraform state rm` 解除 state 管理。

## 任务 5：创建新对象

创建新的 S3 object：

- key 为 `new.txt`；
- 内容为 `Success`；
- 由现有 assets bucket 管理；
- `base.txt` 继续由 `module.content` 管理；
- 不得重新接管或删除 `retained.txt`。

## 任务 6：创建输出和文件

创建以下 output：

```text
bucket_names
iam_user_names
security_group_id
security_group_rule_ids
managed_object_keys
```

同时生成：

```text
generated/s3.txt
generated/iam-users.txt
generated/security.txt
```

要求：

- `s3.txt`：两个受管 bucket 的名称；
- `iam-users.txt`：三个受管 IAM user 的名称；
- `security.txt`：安全组 ID 和两条规则的 ID；
- 不得硬编码资源 ID，内容必须来自 Terraform 表达式或 output。

## 完成标准

完成后执行格式化、初始化、验证和 plan，并检查 state 地址、基线 ID、对象内容和 provider alias。确认 `retained.txt` 仍为 `KEEP-ME`，新对象内容为 `Success`，最终 plan 为：

```text
0 to add, 0 to change, 0 to destroy
```

只有满足上述条件后，才可以执行 apply。

