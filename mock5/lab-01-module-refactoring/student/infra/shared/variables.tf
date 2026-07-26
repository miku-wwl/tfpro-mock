variable "aws_region" { type = string }
variable "localstack_endpoint" { type = string }
variable "name_stem" { type = string }
variable "vpc_cidr" { type = string }
variable "segment_definitions" {
  type = list(object({ key = string, cidr_block = string, availability_zone = string }))
}
variable "security_tiers" { type = map(object({ description = string })) }
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
variable "artifact_object_key" { type = string }
