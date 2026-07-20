variable "rules_format" {
  description = "Input format to load: csv, json, or yaml."
  type        = string
  default     = "csv"

  validation {
    condition     = contains(["csv", "json", "yaml"], var.rules_format)
    error_message = "rules_format must be csv, json, or yaml."
  }
}
