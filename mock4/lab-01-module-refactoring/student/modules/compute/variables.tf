variable "name_prefix" { type = string }
variable "ami_id" { type = string }
variable "subnet_ids" { type = map(string) }
variable "security_group_ids" { type = map(string) }
variable "instance_profile" { type = string }

variable "instances" {
  type = map(object({
    subnet_key    = string
    instance_type = string
    enabled       = bool
    priority      = number
    description   = optional(string)
    team          = optional(string)
    tags          = optional(map(string), {})
  }))
}
