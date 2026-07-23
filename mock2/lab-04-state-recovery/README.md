# Lab 04 — State 恢复与资源地址保留

> 这是一个独立的 Terraform Professional 风格练习实验，并非官方考试题。

## 实验目标

恢复一个故意设计为不一致的 Terraform 工作区，同时不得删除或替换任何已经存在的云资源。本实验预计用时 **45–55 分钟**，环境要求为 Terraform CLI 1.11.x、Docker Desktop、Docker Compose、LocalStack，以及 Bash 或 PowerShell。

当前环境中的资源分散在配置、Terraform state 和 LocalStack 中，并且三者之间存在不一致。请以保存的基线数据作为资源身份的最终依据。

## 安全规则

- 不要把 `terraform.tfstate` 当作 JSON 直接编辑；
- 不得删除、替换或重新创建任何已经存在的 bucket、IAM user、安全组、安全组规则或对象；
- 不要使用宽泛的 `ignore_changes` 来掩盖 drift；
- 每次 apply 前都要检查保存的 plan，确认没有已有资源会被删除或替换；
- 最终两个工作区的 plan 都必须干净。

## 开始实验

Bash：

```bash
./scripts/setup.sh
./scripts/corrupt-state.sh
```

PowerShell：

```powershell
./scripts/setup.ps1
./scripts/corrupt-state.ps1
```

初始化过程会创建隔离的 LocalStack 环境，将资源身份信息保存到 `bootstrap/baseline/`，并在 `student/` 中准备一份损坏的本地 state。

## 最终 backend 要求

主工作区必须使用预先创建的 S3 backend bucket，并且使用以下精确 key：

```text
tfpro-sim/lab-04/terraform.tfstate
```

`student/auxiliary/` 下的辅助工作区必须使用同一个 backend bucket，并使用以下精确 key：

```text
tfpro-sim/lab-04/auxiliary.tfstate
```

迁移 backend 时必须保留原有的 lineage、serial 递增关系以及资源与地址之间的映射。最终主工作区不得继续使用本地 state。

## 任务 1 — 修复 provider 和 backend 配置

修复 LocalStack provider 配置以及两个 backend 配置。迁移当前本地 state 中的记录，不要创建一个全新的空 remote state。

迁移前后都要确认：

- 相同的真实资源仍然由 state 管理；
- backend key 完全正确；
- state lineage 保持不变；
- backend 迁移不会创建重复资源。

## 任务 2 — 接管已有资源

调整配置和 state，使主 state 最终包含以下精确地址：

```text
aws_s3_bucket.assets
aws_s3_bucket.logs
aws_iam_user.members["alpha"]
aws_iam_user.members["beta"]
aws_iam_user.members["gamma"]
aws_security_group.application
aws_vpc_security_group_ingress_rule.application["https-public"]
aws_vpc_security_group_ingress_rule.application["ops-vpn"]
```

`logs` bucket、安全组和其中一条 ingress rule 已经存在于 LocalStack 中。请根据基线数据和远程 API 推导它们的标识符，不要创建替代资源。

## 任务 3 — 恢复资源地址，避免资源变更

损坏的 state 中包含旧的普通地址、`count` 索引地址，以及已经没有对应配置的地址。需要在不删除或重新创建真实资源的前提下，恢复到最终模型。

必须满足：

- 三个独立的 IAM user 地址消失；
- IAM users 使用要求的 `for_each` 地址表示；
- assets bucket 的旧地址消失；
- 两个使用 `count` 索引的 seed object 迁移为稳定的字符串 key `for_each` 地址；
- base object 由 `module.content` 管理；
- 同一个真实资源不得同时由两个地址管理；
- 每个过期地址都必须被安全处理。

最终 seed object 地址必须是：

```text
aws_s3_object.seeded["warm-up"]
aws_s3_object.seeded["cold-path"]
```

输入顺序不得影响这些地址。

## 任务 4 — 将一个资源拆分到第二个 state

manifest object 初始位于主本地 state 的 root 资源地址。最终必须将它迁移到辅助 state 的多层 module 地址：

```text
module.operations.module.inventory.aws_s3_object.manifest
```

整个迁移过程中必须保持它是同一个远程对象。它不得继续存在于主 state，也不得被两个 state 同时导入或管理。

base object 最终必须位于主 state 的以下一级 module 地址：

```text
module.content.aws_s3_object.base
```

## 任务 5 — 停止管理 retained.txt

完成后必须满足：

- 配置中不再存在 `retained.txt` 的资源块；
- state 中不存在它的地址；
- 远程对象仍然存在；
- 内容仍然精确为 `KEEP-ME`；
- 对象没有被删除或重新创建。

在没有先处理 state 的情况下直接删除资源块是不安全的。

## 任务 6 — 创建一个新的受管对象

在 assets bucket 中创建 `new.txt`，内容必须精确为：

```text
Success
```

`new.txt` 必须由主 state 管理。已有的 `base.txt`、seed objects、manifest object 和 `retained.txt` 都必须保留其远程身份与内容。

## 任务 7 — 输出与生成文件

创建以下 output：

```text
bucket_names
iam_user_names
security_group_id
security_group_rule_ids
managed_object_keys
```

根据 Terraform 管理的值生成以下文件，不得硬编码资源 ID：

```text
generated/s3.txt
generated/iam-users.txt
generated/security.txt
```

预期内容：

- `s3.txt`：两个受管 bucket 的名称；
- `iam-users.txt`：三个 IAM user 的名称；
- `security.txt`：安全组 ID 和两条规则的 ID。

请规范化输出顺序，避免重复 plan 时发生来回变化。

## 完成条件

- 两个 backend key 完全正确；
- 所有要求的最终地址都存在于正确的 state 中；
- 所有旧地址、过期地址和重复地址都已清理；
- 没有任何已有资源的 ID 发生变化；
- `retained.txt` 仍存在于远程环境，但不再由 Terraform 管理；
- `new.txt` 已创建并由 Terraform 管理；
- 生成文件使用动态值且内容稳定；
- 主工作区和辅助工作区的 `terraform plan` 都显示：

```text
0 to add, 0 to change, 0 to destroy
```

完成实验后，或需要进行正式复核时，再使用 Solution 包中的 `VALIDATION.md`。

## Task 6–7 知识点速记

- 使用 `aws_s3_object` 管理新对象时，`key` 是远程对象名，`content` 是对象内容；两者必须分别对应题目要求的 `new.txt` 和 `Success`。
- 新资源只有在 `terraform apply` 后才会真正创建并写入 state；apply 前应先确认 plan 没有 destroy 或 replacement。
- 使用 `output` 暴露 Terraform 管理的值，使用 `local_file` 将这些值生成文件，避免硬编码资源 ID。
- 生成文件中的集合或 map 应排序，保证重复 plan 时内容稳定，避免不必要的文件变更。
