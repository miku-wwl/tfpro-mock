variable "launch_template_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "desired_capacity" {
  type = number
}
