output "bucket_names" {
  value = {
    assets = aws_s3_bucket.assets.id
    logs   = aws_s3_bucket.logs.id
  }
}

output "iam_user_names" {
  value = { for key, user in aws_iam_user.members : key => user.name }
}

output "security_group_id" {
  value = aws_security_group.application.id
}

output "security_group_rule_ids" {
  value = toset([for rule in aws_vpc_security_group_ingress_rule.application : rule.id])
}

output "managed_object_keys" {
  value = tolist(toset(concat(
    [module.content.base_key, aws_s3_object.new.key],
    [for object in aws_s3_object.seeded : object.key]
  )))
}
