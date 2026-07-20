variable "name_seed" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "nodes" {
  type = map(object({
    subnet_key          = string
    security_group_keys = set(string)
    flavor              = string
  }))
}

variable "subnet_ids_by_key" {
  type = map(string)
}

variable "security_group_ids" {
  type = map(string)
}

variable "instance_profile_name" {
  type = string
}
