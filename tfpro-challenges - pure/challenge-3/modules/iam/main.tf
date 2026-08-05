terraform {
  required_version = "= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.80.0"
    }
  }
}

resource "aws_iam_user" "lb" {
  count = 1
  name  = "success-user"
}

resource "aws_iam_user_policy" "lb_ro" {
  name = "ec2-describe-policy"
  user = "success-user"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}