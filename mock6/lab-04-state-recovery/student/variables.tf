variable "lab_id" {
  type = string
}

variable "region" {
  type = string
}

variable "assets_bucket_name" {
  type = string
}

variable "logs_bucket_name" {
  type = string
}

variable "backend_bucket_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "security_group_name" {
  type = string
}

variable "iam_user_names" {
  type = object({
    alpha = string
    beta  = string
    gamma = string
  })
}
