# Task1 CLI 记录

目标：将 Terraform 权威状态配置到已有的 S3 backend，使用固定 key：
`tfpro-sim/lab-04/terraform.tfstate`

## 执行命令

```powershell
terraform init -reconfigure -input=false `
  -backend-config backend.hcl `
  -backend-config access_key=test `
  -backend-config secret_key=test `
  -backend-config endpoint=http://localhost:4566 `
  -backend-config skip_credentials_validation=true `
  -backend-config skip_region_validation=true `
  -backend-config skip_requesting_account_id=true `
  -backend-config force_path_style=true

terraform plan -input=false -no-color
terraform state list
```

## 验证结果

- backend 初始化成功并使用指定 key。
- `terraform plan` 返回 `No changes`。
- `terraform state list` 成功从 S3 backend 读取状态。
- 未直接编辑 Terraform state JSON。
