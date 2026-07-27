resource "local_file" "s3" {
  filename = "${path.module}/generated/s3.txt"
  content = format("%s\n", join("\n", sort([
    aws_s3_bucket.assets.id,
    aws_s3_bucket.logs.id,
  ])))
}

resource "local_file" "iam_users" {
  filename = "${path.module}/generated/iam-users.txt"
  content = format("%s\n", join("\n", sort([
    for user in values(aws_iam_user.members) : user.name
  ])))
}

resource "local_file" "security" {
  filename = "${path.module}/generated/security.txt"
  content = format("%s\n", join("\n", concat(
    [aws_security_group.application.id],
    sort([for rule in values(aws_vpc_security_group_ingress_rule.application) : rule.security_group_rule_id]),
  )))
}
