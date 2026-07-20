variable "environment" {
  type        = string
  description = "Environment label used in names and tags."
}

variable "address_space" {
  type = object({
    cidr               = string
    subnet_cidrs       = list(string)
    availability_zones = list(string)
  })

  validation {
    condition     = length(var.address_space.subnet_cidrs) == length(var.address_space.availability_zones)
    error_message = "Each subnet CIDR must have a matching availability zone."
  }
}

variable "security_tiers" {
  type = set(string)
}

variable "workloads" {
  type = map(object({
    subnet_index   = number
    instance_type  = string
    security_tiers = set(string)
  }))
}

variable "archive" {
  type = object({
    region     = string
    object_key = string
  })
}

variable "access_roles" {
  type = map(object({
    role_name        = string
    profile_name     = string
    permission_scope = string
  }))
}

variable "common_tags" {
  type = map(string)
}
