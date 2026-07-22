terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.82.0"
      configuration_aliases = [aws.identity]
    }
  }
}
