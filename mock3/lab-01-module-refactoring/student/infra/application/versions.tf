terraform {
  required_version = ">= 1.11.0, < 1.15.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.80.0, < 6.0.0" }
  }
}
