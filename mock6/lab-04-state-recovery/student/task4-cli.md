# Task4 CLI 记录

目标：将受管的 `new.txt` 内容设置为题目要求的 `Success`。

## 执行命令

```powershell
terraform plan -input=false -no-color
terraform apply -input=false
terraform plan -input=false -no-color
```

## 验证结果

- `aws_s3_object.delivery_receipt` 配置已将内容改为 `Success`。
- apply 前 plan 仅显示 `new.txt` 的原位更新。
- apply 后应再次 plan 验证为 0 changes。
- `base.txt` 未修改，内容继续为 `BASE-CONTENT`。
