resource "local_file" "s3_inventory" {
  filename = "${path.module}/generated/s3.txt"
  content = join("\n", sort([
    aws_s3_bucket.assets.bucket,
    aws_s3_bucket.logs.bucket,
  ]))
}

resource "local_file" "iam_inventory" {
  filename = "${path.module}/generated/iam-users.txt"
  content  = join("\n", sort([for user in aws_iam_user.members : user.name]))
}

resource "local_file" "security_inventory" {
  filename = "${path.module}/generated/security.txt"
  content = join("\n", concat(
    [aws_security_group.application.id],
    sort([
      aws_vpc_security_group_ingress_rule.client_https.id,
      aws_vpc_security_group_ingress_rule.operations_https.id,
    ]),
  ))
}
