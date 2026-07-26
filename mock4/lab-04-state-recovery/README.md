# 实验 04：状态恢复与稳定的数据规范化

> 独立的 Terraform Professional 练习模拟题，不代表官方考试题目。

**建议用时：**45–55 分钟  
**难度：**90–94 / 100  
**环境：**Terraform CLI 1.11.x、Docker Desktop、Docker Compose、LocalStack、AWS CLI，以及 Bash 或 PowerShell

## 场景

一次中断的迁移完成后，你接手了一个部分由 Terraform 管理的 LocalStack 环境。部分资源仍使用旧的状态地址记录；部分资源已经存在于远端，但尚未纳入状态；有一个状态地址已成为孤儿地址；S3 后端配置错误；当前配置也与远端对象不一致。

恢复清单分散在 CSV、JSON 和 YAML 三种文件中，而且原始值类型刻意设置得不一致。你必须先将它们规范化为统一、稳定的数据模型，然后再用这些数据驱动 `for_each` 和资源导入决策。

不要重新创建已有基础设施，也不要直接编辑状态 JSON 文件。

## 开始实验

在实验根目录执行：

```bash
./scripts/setup.sh
```

PowerShell：

```powershell
./scripts/setup.ps1
```

初始化脚本会创建 LocalStack 资源，保存 `baseline/baseline.json`，并在 `student/` 中准备一份受损的本地状态。

## 初始状态

你应当会遇到以下情况：

- 本地状态只包含真实环境的一部分资源。
- 后端 key、区域和 S3 endpoint 均配置错误。
- assets 存储桶记录为 `aws_s3_bucket.primary`。
- IAM 用户记录为 `aws_iam_user.alpha`、`aws_iam_user.beta` 和 `aws_iam_user.gamma`。
- logs 存储桶和应用安全组已存在于远端，但不在状态中。有一条入站规则使用旧地址记录，另一条规则仅存在于远端。
- `aws_s3_object.retained` 当前由 Terraform 管理，但必须在不删除远端对象的情况下解除管理。
- `aws_s3_object.retired_probe` 是一个孤儿状态地址。
- 如果直接应用当前的 assets 存储桶配置，Terraform 会尝试替换已有存储桶。
- 标签和 provider 设置与基线不一致。
- 恢复清单中包含重复的逻辑记录，并且原始值类型不统一。

## 任务 1：修复并迁移后端

最终后端必须使用 S3，并且必须使用以下精确的 key：

```text
tfpro-sim/lab-04/terraform.tfstate
```

要求：

- 使用 `student/baseline/backend.hcl` 中记录的后端存储桶。
- 修正区域和 LocalStack S3 endpoint。
- 迁移当前本地状态，确保不丢失任何记录。
- 不得创建重复资源。
- 迁移完成后不得继续使用本地状态。

## 任务 2：规范化恢复清单

读取 `student/data/` 下的三个文件：

- `recovery.csv`
- `recovery.json`
- `recovery.yaml`

将所有启用的记录规范化为统一对象结构，并包含以下语义字段：

- `kind`
- `address_key`
- 可为空的 `remote_suffix`
- 布尔值 `enabled`
- 数值 `priority`
- 布尔值 `keep_remote`
- `description`
- 源格式

规则：

- CSV 中的空字符串，以及 JSON/YAML 中的 `null`，必须以一致的方式规范化。
- 真实的 `null` 不能在规范化对象中被无声地转换为空字符串。
- 必须以确定性的方式解决重复逻辑身份：优先级较高的记录胜出；优先级相同也必须能够确定性地决出结果。
- 不得使用输入行号作为永久 key。
- 即使输入顺序发生变化，资源地址也不能改变。
- 使用合适的集合函数，例如 `flatten`、`merge`、`distinct`/`toset`、`lookup` 或等效方法。

### 表达式陷阱

如果只使用 `kind:address_key` 作为对象推导式的 key，会因为输入中存在重复逻辑记录而触发 **duplicate object key** 错误。

如果条件表达式中“启用记录返回对象、禁用记录返回列表”，会触发 **conditional branches type mismatch**。应确保两个分支的类型兼容，或使用对象推导式的 `if` 子句进行过滤。

## 任务 3：接管已有资源

最终状态必须包含以下地址：

```text
aws_s3_bucket.assets
aws_s3_bucket.logs
aws_iam_user.members["alpha"]
aws_iam_user.members["beta"]
aws_iam_user.members["gamma"]
aws_security_group.application
aws_vpc_security_group_ingress_rule.inbound["ops-tcp-8443"]
aws_vpc_security_group_ingress_rule.inbound["audit-tcp-9443"]
```

要求：

- 使用规范化后的 map 驱动入站规则的导入目标。
- 正确区分 Terraform 资源地址和远端导入 ID。
- 在状态命令中正确引用 `for_each` 的字符串 key。
- 导入后继续修复配置，直到 plan 不再对已接管资源提出任何变更。
- 不要泄露或猜测 ID；应使用 `baseline/baseline.json` 和状态检查结果。

## 任务 4：迁移旧地址

最终要求：

- `aws_s3_bucket.primary` 不得存在。
- `aws_iam_user.alpha`、`aws_iam_user.beta` 和 `aws_iam_user.gamma` 不得存在。
- `aws_s3_object.retired_probe` 不得存在。
- `aws_vpc_security_group_ingress_rule.legacy_ops` 不得存在。
- 任何真实资源都不能同时由两个地址管理。
- 地址迁移不得导致销毁/创建替换。

## 任务 5：释放 `retained.txt`

最终要求：

- 配置中不得存在 `retained.txt` 对应的资源块。
- 状态中不得存在该资源地址。
- 远端对象必须继续存在。
- 对象内容必须保持精确的 `KEEP-ME`。
- 不得删除或重新创建该对象。

仅移除资源块是不安全的，因为状态条目仍然存在时，Terraform 会计划删除远端对象。

## 任务 6：创建 `new.txt`

创建一个由 Terraform 管理的 S3 对象：

- key：`new.txt`
- 内容：`Success`

保持 `base.txt` 由 Terraform 管理，且内容不变。

## 任务 7：输出与生成文件

创建以下 outputs：

- `bucket_names`
- `iam_user_names`
- `security_group_id`
- `security_group_rule_ids`
- `managed_object_keys`

使用 Terraform 动态创建以下文件：

- `generated/s3.txt`：两个存储桶名称
- `generated/iam-users.txt`：三个 IAM 用户名称
- `generated/security.txt`：安全组 ID 和两条规则的 ID

要求：

- 不得硬编码资源 ID。
- 生成文件中的行顺序必须稳定。
- set/list 的迭代顺序不能影响文件内容。

## 任务 8：最终验证

生成并检查保存的 plan。

最终结果必须为：

```text
0 to add, 0 to change, 0 to destroy
```

然后运行 solution workflow 中提供的 shuffle 测试，或实现等效测试。对 CSV、JSON 和 YAML 输入重新排序后，不得产生删除/创建操作，也不得导致资源地址发生变化。

## 禁止使用的捷径

- 直接编辑 `terraform.tfstate` 或远端状态 JSON
- 重新创建已有的存储桶、用户、安全组或规则
- 使用宽泛的 `ignore_changes`
- 使用基于行号的 `for_each` key
- 硬编码 LocalStack 生成的 ID
- 释放 `retained.txt` 后再次导入它
- 应用包含意外删除或替换操作的 plan
