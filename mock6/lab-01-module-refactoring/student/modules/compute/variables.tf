variable "name_prefix" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = map(string)
}

variable "instance_profile_name" {
  type = string
}

variable "nodes" {
  type = map(object({
    subnet_key      = string
    security_groups = set(string)
    instance_type   = string
  }))
}

variable "resource_tags" {
  type = map(string)
}
