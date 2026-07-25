variable "name_prefix" {
  type = string
}

variable "subnets" {
  type = map(object({
    cidr        = string
    az          = string
    route_label = optional(string)
  }))
}
