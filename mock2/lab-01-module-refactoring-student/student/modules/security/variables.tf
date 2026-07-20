variable "name_seed" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "groups" {
  type = map(object({
    description = string
  }))
}

variable "rules" {
  type = map(object({
    destination = string
    source      = optional(string)
    cidr        = optional(string)
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))
}
