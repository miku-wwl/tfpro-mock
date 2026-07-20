data "aws_caller_identity" "current" {
  provider = aws.identity
}

module "compute" {
  source = "./modules/compute"

  group_name = "lab02-capacity-group"
}

module "identity" {
  source = "./modules/identity"

  service_accounts = [
    { key = "batch-worker-prod", name = "lab02-batch-worker" },
    { key = "api-gateway", name = "lab02-api-service" },
  ]
}

module "storage" {
  source = "./modules/storage"

  bucket_name = aws_s3_bucket.artifact_store.id
}

output "caller_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "service_accounts" {
  value = module.identity.service_account_names
}
