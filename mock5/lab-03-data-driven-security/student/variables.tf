variable "rules_format" {
  description = "External policy format to decode."
  type        = string
  default     = "csv"

  validation {
    condition     = contains(["csv", "json", "yaml"], var.rules_format)
    error_message = "rules_format must be one of: csv, json, yaml."
  }
}
