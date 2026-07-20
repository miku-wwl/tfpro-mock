variable "ami_id" {
  type = string
}

variable "instances" {
  type = map(object({
    subnet_key          = string
    subnet_index        = number
    security_group_keys = set(string)
    instance_type       = string
    tags                = map(string)
  }))
}

variable "subnet_ids" {
  type = map(string)
}

variable "security_group_ids" {
  type = set(string)
}

variable "instance_profile_name" {
  type = string
}
