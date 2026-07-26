resource "aws_iam_user" "audit_subject" {
  provider = aws.identity
  name     = "lab02-evidence-user"
}
