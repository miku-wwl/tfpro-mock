terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.70.0"
      configuration_aliases = [aws.identity]
    }


  }
}

resource "aws_iam_user" "service_actor" {
  provider = aws.identity
  name     = "lab02-service-actor"
}

output "user_name" {
  value = aws_iam_user.service_actor.name
}
