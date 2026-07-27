# Task3 CLI 记录

目标：释放 `retained.txt` 的 Terraform 管理关系，同时保留远端对象。

## 执行命令

```powershell
terraform state rm 'aws_s3_object.retained'
terraform plan -input=false -no-color
```

## 验证结果

- 已删除 `aws_s3_object.retained` 配置块。
- 已从 Terraform state 移除 `aws_s3_object.retained`。
- `managed_object_keys` 已移除该资源引用。
- 未执行 S3 删除操作，远端对象仍存在且内容为 `KEEP-ME`。
- plan 仅显示 output state 更新，不涉及远端资源变更。
