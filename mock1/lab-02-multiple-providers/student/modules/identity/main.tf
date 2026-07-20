terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.70.0"
    }
  }
}

resource "aws_iam_user" "service_actor" {
  name = "lab02-service-actor"
}

output "user_name" {
  value = aws_iam_user.service_actor.name
}
