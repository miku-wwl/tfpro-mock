variable "aws_region" {
  description = "AWS region used by LocalStack."
  type        = string
  default     = "us-east-1"
}

variable "localstack_endpoint" {
  description = "LocalStack edge endpoint."
  type        = string
  default     = "http://localhost:4566"
}

variable "localstack_access_key" {
  description = "Non-secret LocalStack access key."
  type        = string
  default     = "test"
}

variable "localstack_secret_key" {
  description = "Non-secret LocalStack secret key."
  type        = string
  sensitive   = true
  default     = "test"
}

variable "ami_id" {
  description = "Synthetic AMI identifier accepted by LocalStack."
  type        = string
  default     = "ami-0f1e2d3c4b5a69788"
}
