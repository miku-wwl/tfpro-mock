terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"

      configuration_aliases = [aws.workload]
    }
  }
}

variable "account_id" {
  type = string
}

variable "access_roles" {
  type = map(object({
    role_name        = string
    profile_name     = string
    permission_scope = string
  }))
}

variable "name_prefix" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
