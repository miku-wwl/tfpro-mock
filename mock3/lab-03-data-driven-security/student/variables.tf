variable "rules_format" {
  description = "External rule file format to load."
  type        = string
  default     = "csv"

  validation {
    condition     = contains(["csv", "json", "yaml"], var.rules_format)
    error_message = "rules_format must be csv, json, or yaml."
  }
}

variable "lab_id" {
  description = "Tag used to discover the pre-created lab infrastructure."
  type        = string
  default     = "tfpro-lab-03"
}
