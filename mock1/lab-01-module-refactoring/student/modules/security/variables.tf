# Draft contract issue: a resource vpc_id argument requires one string.
variable "vpc_id" {
  type = list(string)
}

variable "security_groups" {
  type = map(object({
    name        = string
    description = string
    tags        = map(string)
  }))
}

variable "ingress_rules" {
  type = map(object({
    target_group = string
    source_group = optional(string)
    source_cidr  = optional(string)
    port         = number
    protocol     = string
    description  = string
    tags         = map(string)
  }))
}
