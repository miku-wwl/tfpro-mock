terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"

      configuration_aliases = [aws.network, aws.readonly]
    }
  }
}

variable "vpc_id" {
  type = string
}

variable "security_tiers" {
  type = set(string)
}

variable "name_prefix" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
