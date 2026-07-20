output "bucket_names" {
  value = toset([
    aws_s3_bucket.primary.id,
    aws_s3_bucket.logs.id,
  ])
}

output "iam_user_names" {
  value = [
    aws_iam_user.alpha.name,
    aws_iam_user.beta.name,
    aws_iam_user.gamma.name,
  ]
}

output "security_group_id" {
  value = aws_security_group.application.id
}

output "security_group_rule_ids" {
  value = toset([
    for rule in values(aws_vpc_security_group_ingress_rule.application) : rule.security_group_rule_id
  ])
}

output "managed_object_keys" {
  value = [
    aws_s3_object.base.key,
    aws_s3_object.retained.key,
  ]
}
