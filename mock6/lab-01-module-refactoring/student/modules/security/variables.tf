variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "group_definitions" {
  type = map(object({
    description = string
  }))
}

variable "resource_tags" {
  type = map(string)
}

variable "operator_cidrs" {
  type = set(string)
}
