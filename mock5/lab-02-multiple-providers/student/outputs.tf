output "compute_pool_name" {
  value = module.compute.group_name
}

output "identity_principal" {
  value = module.identity.user_arn
}

output "object_key" {
  value = aws_s3_object.artifact.key
}

output "account" {
  value = data.aws_caller_identity.current.account_id
}
