variable "environment" { type = string }
variable "workloads" { type = map(object({ subnet_index = number, instance_type = string, security_tiers = set(string) })) }
variable "common_tags" { type = map(string) }
variable "ami" {
  type    = string
  default = "ami-f5a14ea6"
}
variable "account_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_ids" { type = map(string) }
variable "instance_profile_name" { type = string }
