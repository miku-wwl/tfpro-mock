variable "aws_region" { type = string }
variable "localstack_endpoint" { type = string }
variable "local_access_key" { type = string }
variable "local_secret_key" { type = string }
variable "network_layout" {
  type = object({ vpc_cidr = string, subnet_cidrs = list(string), availability_zones = list(string) })
}
variable "operator_cidrs" { type = set(string) }
variable "business_metadata" {
  type = object({ owner = string, cost_centre = string, service = string, stage = string })
}
