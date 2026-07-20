variable "aws_region" {
  type        = string
  description = "Region used by LocalStack."
  default     = "us-east-1"
}

variable "localstack_endpoint" {
  type        = string
  description = "LocalStack edge endpoint."
  default     = "http://localhost:4566"
}

variable "lab_tag" {
  type        = string
  description = "Discovery tag applied by the bootstrap stack."
  default     = "lab-03-data-driven-security"
}

variable "rules_format" {
  type        = string
  description = "External rule catalogue format."
  default     = "csv"

  validation {
    condition     = contains(["csv", "json", "yaml"], var.rules_format)
    error_message = "rules_format must be csv, json, or yaml."
  }
}
