variable "naming" {
  type = object({
    label  = string
    suffix = string
  })
}

variable "tags" {
  type = map(string)
}