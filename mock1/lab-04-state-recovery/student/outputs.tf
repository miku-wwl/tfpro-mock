output "bucket_names" {
  value = toset([
    aws_s3_bucket.assets.bucket,
    aws_s3_bucket.logs.bucket,
  ])
}

output "iam_user_names" {
  value = [for user in aws_iam_user.members : user.name]
}

output "security_group_id" {
  value = aws_security_group.application.id
}

output "security_group_rule_ids" {
  value = [for rule in aws_security_group_rule.inbound : rule.security_group_rule_id]
}

output "managed_object_keys" {
  value = [
    aws_s3_object.base.key,
  ]
}
