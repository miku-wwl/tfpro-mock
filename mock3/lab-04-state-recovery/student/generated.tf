resource "local_file" "s3" {
  filename = "${path.module}/generated/s3.txt"
  content  = "${join("\n", tolist(toset([aws_s3_bucket.assets.id, aws_s3_bucket.logs.id])))}\n"
}

resource "local_file" "iam_users" {
  filename = "${path.module}/generated/iam-users.txt"
  content  = "${join("\n", tolist(toset([for user in aws_iam_user.members : user.name])))}\n"
}

resource "local_file" "security" {
  filename = "${path.module}/generated/security.txt"
  content = "${join("\n", concat(
    [aws_security_group.application.id],
    tolist(toset([for rule in aws_vpc_security_group_ingress_rule.rules : rule.id]))
  ))}\n"
}
