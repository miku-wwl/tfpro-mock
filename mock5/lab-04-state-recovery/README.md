# 实验 04：严格约束下的状态恢复

> 独立的 Terraform Professional 模拟练习，不代表官方考试题目。

## 场景

一次部分迁移后，LocalStack 环境处于不一致但可以恢复的状态。部分远端资源仍记录在旧地址下，部分资源存在但没有状态记录；有一条状态记录已经找不到对应的远端对象；后端配置也指向了错误位置。请在**不替换已有 AWS 资源**的前提下恢复配置和状态。

建议用时：**45–55 分钟**。目标难度：**90–94 / 100**。

开始前请运行 `scripts/setup.sh` 或 `scripts/setup.ps1`。初始化过程会创建隔离的 LocalStack 环境、写入运行时基线，并准备受损的本地状态。由于它会对 LocalStack 执行 Terraform apply，因此需要明确确认。

## 权威实现约定

最终实现会根据配置结构和状态身份进行评估，而不仅是查看 LocalStack 中的可见结果。

| 文件 | 必需资源类型 | 精确 block 数量 | 必需的最终标签或 key |
|---|---:|---:|---|
| `student/storage.tf` | `aws_s3_bucket` | 2 | `assets`、`logs` |
| `student/storage.tf` | `aws_s3_object` | 2 | `base`、`new` |
| `student/identity.tf` | `aws_iam_user` | 1 | 使用 `for_each` 的 `members` |
| `student/security.tf` | `aws_security_group` | 1 | `application` |
| `student/security.tf` | `aws_vpc_security_group_ingress_rule` | 1 | 使用 `for_each` 的 `application` |
| `student/generated.tf` | `local_file` | 3 | 每个必需生成文件各一个 block |

不得使用子模块。所有资源、provider、输出、生成文件和后端声明都必须属于 `student/` 中的根模块。即使子模块生成了相同基础设施，也不符合本实验要求。

在 `student/providers.tf` 中只能使用一个未命名的默认 `aws` provider，并且必须指向 `us-east-1` 中的 LocalStack。不得在 provider block 或 Terraform 变量中写入 access key 或 secret key。初始化脚本通过环境变量提供一次性 `test` 凭据。

后端类型必须为 `s3`，在 `student/versions.tf` 中声明，并在 `student/backend.hcl` 中提供运行时设置。最终后端 key 必须严格为：

```text
tfpro-sim/lab-04/terraform.tfstate
```

最终状态不得保留在本地，也不得使用任何相近但不同的 key。

## 任务 1：修复并迁移后端

题目提供的后端设置包含一个看似合理但错误的 key，以及错误的连接信息。请修复配置，并将当前本地状态迁移到已有的 LocalStack 状态存储桶中。

迁移必须保留每一条有效状态记录。不得从空的远程状态开始，不得创建重复资源，也不得在最终结果中留下第二份仍在使用的本地状态。

## 任务 2：接管所有必需的已有资源

最终状态必须包含以下精确地址：

```text
aws_s3_bucket.assets
aws_s3_bucket.logs
aws_iam_user.members["alpha"]
aws_iam_user.members["beta"]
aws_iam_user.members["gamma"]
aws_security_group.application
aws_vpc_security_group_ingress_rule.application["admin-console"]
aws_vpc_security_group_ingress_rule.application["service-http"]
aws_s3_object.base
aws_s3_object.new
```

请根据运行时基线、provider 文档、远端检查结果和现有状态推导导入身份。本文档不会提供完整的导入 ID 或完整的导入命令。

完成接管后，使配置与远端资源一致。仅导入成功并不够；如果后续 plan 仍提出非预期变更，也不算完成。

## 任务 3：迁移旧地址且不得重建

初始受损状态包含独立的 IAM 用户地址和旧版存储桶地址。请将现有资源身份迁移到目标地址。

完成时，以下地址必须不存在：

```text
aws_s3_bucket.primary
aws_iam_user.alpha
aws_iam_user.beta
aws_iam_user.gamma
aws_s3_object.retired_marker
aws_s3_object.retained
```

如果通过销毁并重新创建远端资源来实现地址变更，则不得分。同一个真实资源不能同时由旧地址和目标地址管理。

## 任务 4：停止管理保留对象

Terraform 当前管理着 `retained.txt`。请移除其资源块和状态记录，同时保留已有远端对象。

完成时：

- 对象仍存在于 assets 存储桶中；
- 内容必须精确为 `KEEP-ME`；
- 对象没有被删除并重新上传；
- 没有 Terraform 状态地址管理它。

删除资源块并接受远端删除是不正确的，即使之后重新上传相同内容也不行。

## 任务 5：创建新的受管对象

使用 `student/storage.tf` 中要求的 `aws_s3_object.new` block，在 assets 存储桶中创建 `new.txt`，内容必须精确为 `Success`。

`base.txt` 必须保留原有远端身份和管理关系。最终受管对象集合为 `base.txt` 和 `new.txt`；`retained.txt` 继续存在于远端，但不再由 Terraform 管理。

## 输出约定

在 `student/outputs.tf` 中定义所有输出。值必须由 Terraform 资源计算得到，不得硬编码远端 ID 或运行时名称。

| 输出名称 | 精确结果类型 | 必需内容 |
|---|---|---|
| `bucket_names` | `list(string)` | assets 和 logs 存储桶名称，排序后输出 |
| `iam_user_names` | `list(string)` | 三个用户名称，排序后输出 |
| `security_group_id` | `string` | application 安全组 ID |
| `security_group_rule_ids` | `list(string)` | 两个规则 ID，按稳定规则 key 排序 |
| `managed_object_keys` | `set(string)` | 精确包含 `base.txt` 和 `new.txt` |

set/list 的类型差异很重要。即使命令行显示看起来相似，但 Terraform 类型不正确，也不算完成。

## 生成文件约定

在 `student/generated.tf` 中使用恰好三个独立的 `local_file` 资源 block：

- `generated/s3.txt`：两个存储桶名称，每行一个，按排序后的顺序写入；
- `generated/iam-users.txt`：三个 IAM 用户名称，每行一个，按排序后的顺序写入；
- `generated/security.txt`：先写安全组 ID，再写两个规则 ID，每行一个；规则 ID 按稳定 key 排序。

文件内容必须来自资源属性。使用带 `for_each` 的单个 `local_file` block 虽然可能生成正确文件，但违反要求的 block 数量。使用 shell 重定向或手动写入文件也不符合约定。

## 状态与安全约束

可以使用常规 Terraform 状态和导入操作，但不得直接编辑状态 JSON。

不得使用宽泛的 `lifecycle.ignore_changes` 掩盖漂移，也不得替换为已弃用或其他资源类型。特别是，入站规则必须使用恰好一个带 `for_each` 的 `aws_vpc_security_group_ingress_rule` block；多个 block、`count`、`aws_security_group_rule` 或基于索引的 key 都不符合要求。

应用前必须检查保存的 plan。已有 AWS 资源不得出现删除或替换操作。恢复过程中唯一预期的 AWS 创建操作是 `aws_s3_object.new`；三个 `local_file` 资源预期会在本地创建。批准的 apply 完成后，最终 plan 必须报告 **0 to add, 0 to change, 0 to destroy**。

## 容易失分的做法

以下做法可能看起来能运行，但明确不符合要求：

- 因为 Terraform 仍能运行就保留本地状态；
- 在目标名称下销毁并重新创建资源；
- 删除并重新上传 `retained.txt`；
- 使用一个带 `for_each` 的 `local_file` block；
- 使用三个 IAM user block 或 `count`，而不是要求的 `for_each` block；
- 通过硬编码基线值生成输出；
- 使用其他安全组规则资源类型；
- 使用宽泛的生命周期忽略规则来压制差异。

## 完成证据

收集并检查以下内容：

1. 最终后端配置和状态位置；
2. 包含所有目标地址且不含旧地址的 `terraform state list`；
3. 关键资源的 `terraform state show`；
4. 显示 0/0/0 的最终保存 plan；
5. LocalStack 对保留对象和新对象内容的检查结果；
6. 使用 `terraform output -json` 检查输出类型和值；
7. 生成文件内容；
8. 存储桶、用户、安全组、规则和 `base.txt` 的基线身份对比。
