output "bucket_names" {
  value = sort([
    aws_s3_bucket.assets.bucket,
    aws_s3_bucket.logs.bucket,
  ])
}

output "iam_user_names" {
  value = sort([
    for user in values(aws_iam_user.members) : user.name
  ])
}

output "security_group_id" {
  value = aws_security_group.application.id
}

output "security_group_rule_ids" {
  value = {
    for key in sort(keys(aws_vpc_security_group_ingress_rule.inbound)) :
    key => aws_vpc_security_group_ingress_rule.inbound[key].id
  }
}

output "managed_object_keys" {
  value = sort([
    aws_s3_object.base.key,
    aws_s3_object.new.key,
  ])
}
