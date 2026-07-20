output "caller_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "compute_asg_id" {
  value = module.compute.autoscaling_group_id
}

output "identity_policy_arn" {
  value = module.identity.policy_arn
}

output "storage_bucket_arn" {
  value = module.storage.bucket_arn
}
