variable "aws_region" { type = string }
variable "localstack_endpoint" { type = string }
variable "name_stem" { type = string }
variable "shared_name_token" { type = string }
variable "base_ami" { type = string }
variable "subnet_ids" { type = map(string) }
variable "security_group_ids" { type = map(string) }
variable "workload_roles" {
  type = map(object({ segment_key = string, security_tier = string, instance_type = string }))
}
