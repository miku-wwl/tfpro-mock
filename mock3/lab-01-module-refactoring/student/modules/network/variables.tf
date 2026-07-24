terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"

      configuration_aliases = [aws.network]
    }
  }
}

variable "cidr" {
  type = string
}

variable "subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "name_prefix" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
