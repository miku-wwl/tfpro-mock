# Lab 04 — State 恢复与 Backend 迁移

> 独立的 Terraform Professional 练习 Lab，并非 HashiCorp 官方考试题目。

## 场景

一次此前的迁移在中途停止。基础设施仍然存在于 LocalStack 中，但 Terraform 配置、本地 state 和 backend 设置已不再一致。

你的任务是：在不重新创建已有资源的前提下，恢复 Terraform 对这些资源的管理；将 state 迁移到指定的 S3 backend；停止管理一个需要保留的对象但不删除它；并新增一个受管理对象。

**目标时长：**45–55 分钟
**目标难度：**Terraform Professional 90–94/100

## 环境

- Terraform CLI 1.11.x
- 已安装 Docker Compose 的 Docker Desktop
- LocalStack
- Bash 或 PowerShell

不需要真实 AWS 凭证。脚本只使用针对 `http://localhost:4566` 的一次性测试凭证 `test` / `test`。

## 开始 Lab

Bash：

```bash
./scripts/setup.sh
cd student
```

PowerShell：

```powershell
./scripts/setup.ps1
Set-Location student
```

初始化脚本会创建远程资源、在 `bootstrap/baseline/` 下保存基线，并在 `student/terraform.tfstate` 中准备一个刻意不一致的本地 state。

## 初始损坏状态

完成初始化后，应当存在以下所有情况：

- 当前使用的是 local state；同时存在一个 S3 backend 配置文件，但其中的 key 接近正确值而非正确值，连接设置也不正确。
- assets bucket 在 state 中的地址是 `aws_s3_bucket.primary`，而目标配置使用 `aws_s3_bucket.assets`。
- 三个 IAM user 在 state 中的地址分别是 `aws_iam_user.alpha`、`aws_iam_user.beta` 和 `aws_iam_user.gamma`。
- 目标 IAM resource 使用 `for_each`，其中一个 map key 拼写错误。
- logs bucket 和 application security group 存在于远程环境，但不在 state 中。
- 一条 ingress rule 记录在旧地址；另一条 ingress rule 不在 state 中。
- `base.txt` 和 `retained.txt` 在起始 state 中都受 Terraform 管理。
- 一个过期的 IAM 地址仍留在 state 中，但对应的远程 IAM user 已不存在。
- 起始配置中存在 provider、tag 和物理名称漂移。

使用 `terraform state list`、`terraform state show`、基线文件及普通 Terraform plan 来理解环境。不得编辑 state JSON。

## 任务 1 — 修复并迁移 Backend

配置并使用初始化脚本创建的 S3 backend。

最终 backend key 必须精确为：

```text
tfpro-sim/lab-04/terraform.tfstate
```

要求：

- 迁移现有本地 state；不得以空的远程 state 开始。
- 迁移过程中保留每一条有效的 state 记录。
- 修正 backend region 和 LocalStack S3 endpoint。
- 不得继续使用接近正确值的 backend key。
- 完成 Lab 后不得再使用 local state。

## 任务 2 — 接管已有资源

最终 state 必须包含以下精确地址：

```text
aws_s3_bucket.assets
aws_s3_bucket.logs
aws_iam_user.members["alpha"]
aws_iam_user.members["beta"]
aws_iam_user.members["gamma"]
aws_security_group.application
aws_security_group_rule.inbound["api"]
aws_security_group_rule.inbound["ops"]
aws_s3_object.base
```

使用基线数据和远程检查来确定 import identifier。README 故意不会提供完整的 import 命令或完整的 import identifier。

接管资源后，应使配置与远程对象一致。不得使用范围过大的 `ignore_changes` 来掩盖漂移。

## 任务 3 — 迁移并清理 State 地址

在不销毁或重新创建基础设施的前提下完成地址迁移。

最终要求：

- `aws_s3_bucket.primary` 不存在。
- `aws_iam_user.alpha`、`aws_iam_user.beta` 和 `aws_iam_user.gamma` 不存在。
- 旧 ingress-rule 地址不存在。
- 过期 IAM 地址不存在。
- 同一个真实远程资源不得同时由两个地址管理。
- IAM `for_each` key 必须精确为 `alpha`、`beta` 和 `gamma`。

如果 plan 对现有 bucket、user、security group 或 ingress rule 提出 delete/create 或 replacement 操作，则不可接受。

## 任务 4 — 停止管理 `retained.txt`，但不得删除它

将 `retained.txt` 从 Terraform 管理中移除，同时保留远程对象。

最终要求：

- 配置中不存在它的 resource block。
- state 中不存在它的地址。
- assets bucket 中的远程 key `retained.txt` 仍然存在。
- 其内容必须仍精确为 `KEEP-ME`。
- 整个练习过程中不得删除并重新创建它。

## 任务 5 — 新增对象并完成输出

创建一个受 Terraform 管理的 S3 object：

```text
key     = new.txt
content = Success
```

创建以下 Terraform outputs：

- `bucket_names`
- `iam_user_names`
- `security_group_id`
- `security_group_rule_ids`
- `managed_object_keys`

从 Terraform value 动态生成以下文件：

```text
generated/s3.txt
generated/iam-users.txt
generated/security.txt
```

文件内容要求：

- `s3.txt`：两个受管理 bucket 的名称。
- `iam-users.txt`：三个 IAM user 的名称。
- `security.txt`：security group ID，后接两个 ingress-rule ID。

必须使用确定性排序。不得硬编码远程 ID。

## 最终验收标准

在认为 Lab 完成前，必须满足：

1. `terraform fmt -check -recursive` 通过。
2. `terraform validate` 通过。
3. `terraform state list` 包含所有目标地址，且不包含任何旧地址。
4. backend 使用精确要求的 key。
5. 原有 bucket 名称、IAM user 名称、security group ID 和 rule identity 均与基线一致。
6. `retained.txt` 仍存在、内容为 `KEEP-ME`，且不在 state 中。
7. `new.txt` 存在、内容为 `Success`，且在 state 中。
8. 生成的文件包含从 Terraform 动态得出的值，并使用稳定排序。
9. 最终 plan 报告 **0 to add, 0 to change, 0 to destroy**。

## 禁止的捷径

- 不得直接编辑 `terraform.tfstate` 或 backend state JSON。
- 不得为了修复地址而删除并重新创建已有资源。
- 不得将同一个远程对象 import 到多个活跃地址。
- 不得使用范围过大的 lifecycle ignore 来隐藏配置漂移。
- 不得在任何文件中写入真实 AWS 凭证。
- 未先审查保存的 plan 前，不得运行破坏性命令。

## 重置

Bash：

```bash
./scripts/reset.sh
```

PowerShell：

```powershell
./scripts/reset.ps1
```
