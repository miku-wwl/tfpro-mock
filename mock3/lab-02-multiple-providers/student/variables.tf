variable "localstack_endpoint" {
  type        = string
  description = "LocalStack edge endpoint"
  default     = "http://localhost:4566"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "artifact_content" {
  type    = string
  default = "ORIGINAL-CONTENT"
}
