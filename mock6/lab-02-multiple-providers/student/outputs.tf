output "observed_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "artifact_bucket" {
  value = module.storage.bucket_id
}
