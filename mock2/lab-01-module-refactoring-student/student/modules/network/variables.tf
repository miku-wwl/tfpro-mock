variable "name_seed" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "segment_specs" {
  type = list(object({
    key  = string
    cidr = string
    az   = string
  }))
}
