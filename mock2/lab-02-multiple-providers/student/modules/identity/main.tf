resource "aws_iam_user" "pipeline_identity" {
  provider = aws.identity

  name = "lab02-pipeline-identity"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_user" "service_accounts" {
  provider = aws.identity

  for_each = var.service_accounts
  name     = each.value.name

  lifecycle {
    prevent_destroy = true
  }
}

output "service_account_names" {

  value = {
    for key, user in aws_iam_user.service_accounts : key => user.name
  }
}
