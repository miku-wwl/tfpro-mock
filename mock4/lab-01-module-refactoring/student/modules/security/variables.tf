variable "name_prefix" { type = string }
variable "vpc_id" { type = string }

variable "groups" {
  type = map(object({
    description = string
  }))
}
