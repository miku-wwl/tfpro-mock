variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "localstack_endpoint" {
  type    = string
  default = "http://localhost:4566"
}

variable "name_prefix" {
  type = string
}

variable "asset_bucket_name" {
  type = string
}

variable "iam_user_names" {
  type = map(string)
}

variable "security_group_id" {
  type = string
}


variable "logs_bucket_name" {
  type = string
}

variable "security_group_name" {
  type = string
}

variable "vpc_id" {
  type = string
}
