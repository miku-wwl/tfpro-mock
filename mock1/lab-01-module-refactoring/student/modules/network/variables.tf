variable "network" {
  type = object({
    cidr_block = string
    tags       = map(string)
  })
}

variable "subnets" {
  type = map(object({
    key               = string
    cidr_block        = string
    availability_zone = string
    tags              = map(string)
  }))
}
