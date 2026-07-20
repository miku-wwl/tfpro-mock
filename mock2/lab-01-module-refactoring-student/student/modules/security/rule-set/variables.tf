variable "group_ids" {
  type = map(string)
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
