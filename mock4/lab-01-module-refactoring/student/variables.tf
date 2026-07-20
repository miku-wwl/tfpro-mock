variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "localstack_endpoint" {
  type    = string
  default = "http://localhost:4566"
}

variable "ami_id" {
  type    = string
  default = "ami-00000000000000001"
}

variable "subnet_specs" {
  type = list(object({
    key         = string
    cidr        = string
    az          = string
    route_label = optional(string)
  }))

  default = [
    {
      key         = "blue"
      cidr        = "10.48.11.0/24"
      az          = "us-east-1a"
      route_label = "interactive"
    },
    {
      key  = "green"
      cidr = "10.48.22.0/24"
      az   = "us-east-1b"
    }
  ]
}
