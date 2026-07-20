variable "name_stem" { type = string }
variable "shared_name_token" { type = string }
variable "base_ami" { type = string }
variable "instance_profile_name" { type = string }

# Draft defects: both required map interfaces are declared as lists.
variable "subnet_ids" { type = list(string) }
variable "security_group_ids" { type = list(string) }

variable "workload_roles" {
  type = map(object({
    segment_key  = string
    security_tier = string
    instance_type = string
  }))
}
