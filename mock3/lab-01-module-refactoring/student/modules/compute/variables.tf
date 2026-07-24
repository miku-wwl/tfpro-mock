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

variable "ami" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = map(string)
}

variable "workloads" {
  type = map(object({
    subnet_index   = number
    instance_type  = string
    security_tiers = set(string)
  }))
}

variable "common_tags" {
  type = map(string)
}
