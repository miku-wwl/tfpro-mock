variable "name_seed" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "segment_specs" {
  type = map(object({
    key  = string
    cidr = string
    az   = string
  }))
}
