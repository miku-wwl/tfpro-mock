variable "rules_format" {
  type        = string
  description = "External policy format to read: csv, json, or yaml."
  default     = "csv"

  validation {
    condition     = contains(["csv", "json", "yaml"], var.rules_format)
    error_message = "rules_format must be csv, json, or yaml."
  }
}
