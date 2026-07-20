variable "naming_context" {
  type = object({
    prefix = string
    stage  = string
  })
}

variable "resource_tags" {
  type = map(string)
}
