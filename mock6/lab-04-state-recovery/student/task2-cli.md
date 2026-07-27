# Task2 CLI 记录

目标：修复 IAM 用户的 Terraform state 地址，使其与配置中的 `for_each` key 和题目要求一致，不改变远端 IAM 用户。

## 执行命令

```powershell
terraform state mv 'aws_iam_user.members["gamma "]' 'aws_iam_user.members["gamma"]'
terraform state list
terraform plan -input=false -no-color
```

## 验证结果

- `gamma` 的 state 地址已迁移为 `aws_iam_user.members["gamma"]`。
- `locals.tf` 中的尾随空格已修复。
- plan 返回 `No changes`。
- 未执行 destroy、import 或远端资源重建。
