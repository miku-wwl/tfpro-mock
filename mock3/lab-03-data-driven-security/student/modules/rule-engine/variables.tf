variable "rules" {
  type = map(any)
}

variable "security_group_ids" {
  type = map(string)
}

variable "subnet_cidrs" {
  type = map(string)
}

variable "account_id" {
  type = string
}
