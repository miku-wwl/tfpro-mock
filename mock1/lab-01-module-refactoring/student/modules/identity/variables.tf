variable "naming" {
  type = object({
    stem   = string
    suffix = string
  })
}

variable "tags" {
  type = map(string)
}
