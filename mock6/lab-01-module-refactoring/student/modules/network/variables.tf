variable "name_prefix" {
  type = string
}

variable "network_spec" {
  type = object({
    vpc_cidr           = string
    subnet_cidrs       = list(string)
    availability_zones = list(string)
  })
}

variable "resource_tags" {
  type = map(string)
}
