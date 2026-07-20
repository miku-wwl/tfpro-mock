locals {
  generated_files = {
    "s3.txt" = join("\n", sort(tolist(toset([
      aws_s3_bucket.primary.id,
      aws_s3_bucket.logs.id,
    ]))))
    "iam-users.txt" = join("\n", sort([
      aws_iam_user.alpha.name,
      aws_iam_user.beta.name,
      aws_iam_user.gamma.name,
    ]))
    "security.txt" = join("\n", concat(
      [aws_security_group.application.id],
      sort([for rule in values(aws_vpc_security_group_ingress_rule.application) : rule.security_group_rule_id]),
    ))
  }
}

resource "local_file" "generated" {
  for_each = local.generated_files

  filename = "${path.module}/generated/${each.key}"
  content  = "${each.value}\n"
}
