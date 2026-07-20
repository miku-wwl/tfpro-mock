resource "aws_iam_policy" "observer" {
  name        = "tfpro-lab02-observer"
  description = "Seeded identity resource for provider-mapping practice"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ec2:Describe*"]
      Resource = "*"
    }]
  })
}
