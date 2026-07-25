variable "name_prefix" { type = string }
variable "vpc_id" { type = string }

variable "groups" {
  type = map(object({
    description = string
  }))
}

variable "cidr_rules" {
  type = map(object({
    destination = string
    cidr        = string
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))
}

variable "peer_rules" {
  type = map(object({
    destination = string
    source      = string
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))
}
