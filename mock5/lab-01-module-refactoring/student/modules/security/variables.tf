variable "name_stem" { type = string }

# Draft defect: wrapping a single VPC ID in a list can be made functional but violates the contract.
variable "vpc_id" { type = list(string) }

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
