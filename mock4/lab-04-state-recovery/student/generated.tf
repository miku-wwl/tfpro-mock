resource "local_file" "s3" {
  filename = "${path.module}/generated/s3.txt"
  content = join("\n", sort([
    aws_s3_bucket.assets.bucket,
    aws_s3_bucket.logs.bucket,
  ]))
}

resource "local_file" "iam_users" {
  filename = "${path.module}/generated/iam-users.txt"
  content = join("\n", sort([
    for user in values(aws_iam_user.members) : user.name
  ]))
}

resource "local_file" "security" {
  filename = "${path.module}/generated/security.txt"
  content = join("\n", concat(
    [aws_security_group.application.id],
    [
      for key in sort(keys(aws_vpc_security_group_ingress_rule.inbound)) :
      aws_vpc_security_group_ingress_rule.inbound[key].id
    ]
  ))
}
