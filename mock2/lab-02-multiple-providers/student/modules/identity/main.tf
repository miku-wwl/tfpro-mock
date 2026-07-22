resource "aws_iam_user" "pipeline_identity" {
  provider = aws.identity

  name = "lab02-pipeline-identity"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_user" "service_accounts" {
  provider = aws.identity

  count = length(var.service_accounts)
  name  = var.service_accounts[count.index].name

  lifecycle {
    prevent_destroy = true
  }
}

output "service_account_names" {
  value = aws_iam_user.service_accounts[*].name
}
