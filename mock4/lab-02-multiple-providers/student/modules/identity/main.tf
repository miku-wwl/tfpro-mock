resource "aws_iam_user" "audit" {
  provider = aws.identity
  name     = "lab02-nimbus-audit-user"
}
