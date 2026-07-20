output "bucket_names" {
  value = toset([aws_s3_bucket.assets.id, aws_s3_bucket.logs.id])
}

output "iam_user_names" {
  value = toset([for user in aws_iam_user.members : user.name])
}

output "security_group_id" {
  value = aws_security_group.application.id
}

output "security_group_rule_ids" {
  value = toset([for rule in aws_vpc_security_group_ingress_rule.rules : rule.id])
}

output "managed_object_keys" {
  value = toset([aws_s3_object.base.key, aws_s3_object.retained.key])
}
