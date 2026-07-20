variable "name_prefix" {
  type = string
}

# Deliberate defect: list identity conflicts with for_each and stable semantic keys.
variable "subnets" {
  type = list(object({
    key  = string
    cidr = string
    az   = string
  }))
}
