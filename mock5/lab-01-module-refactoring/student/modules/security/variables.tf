variable "name_stem" { type = string }

variable "vpc_id" { type = string }

variable "security_tiers" {
  type = map(object({ description = string }))
}

variable "ingress_rules" {
  type = map(object({
    target_tier = string
    source_cidr = optional(string)
    source_tier = optional(string)
    port        = number
    protocol    = string
    description = string
  }))
}
