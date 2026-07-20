variable "aws_region" {
  description = "AWS region exposed by the local emulator."
  type        = string
  default     = "us-east-1"
}

variable "localstack_endpoint" {
  description = "LocalStack edge endpoint."
  type        = string
  default     = "http://localhost:4566"
}

variable "local_access_key" {
  description = "Non-secret credential used only by LocalStack."
  type        = string
  default     = "test"
  sensitive   = true
}

variable "local_secret_key" {
  description = "Non-secret credential used only by LocalStack."
  type        = string
  default     = "test"
  sensitive   = true
}

variable "network_layout" {
  description = "Addressing and placement for the relay platform."
  type        = object({
    vpc_cidr           = string
    subnet_cidrs       = list(string)
    availability_zones = list(string)
  })
}

variable "operator_cidrs" {
  description = "Networks permitted to reach the operations boundary."
  type        = set(string)
}

variable "node_catalog" {
  description = "Workload node placement and security memberships."
  type        = map(object({
    subnet_index    = number
    security_groups = set(string)
    instance_type   = string
  }))
}

variable "business_metadata" {
  description = "Stable business context applied to resources."
  type        = object({
    owner       = string
    cost_centre = string
    service     = string
    stage       = string
  })
}
