variable "environment_suffix" {
  description = "Suffix identifying the pre-provisioned LocalStack environment."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{6}$", var.environment_suffix))
    error_message = "environment_suffix must contain exactly six lowercase alphanumeric characters."
  }
}

variable "rules_format" {
  description = "Policy export format to evaluate."
  type        = string
  default     = "csv"

  validation {
    condition     = contains(["csv", "json", "yaml"], var.rules_format)
    error_message = "rules_format must be csv, json, or yaml."
  }
}
