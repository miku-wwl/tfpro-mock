variable "environment" { type = string }
variable "address_space" {
  type = object({ cidr = string, subnet_cidrs = list(string), availability_zones = list(string) })
}
variable "security_tiers" { type = set(string) }
variable "archive" { type = object({ region = string, object_key = string }) }
variable "access_roles" { type = map(object({ role_name = string, profile_name = string, permission_scope = string })) }
variable "common_tags" { type = map(string) }
