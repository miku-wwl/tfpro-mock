variable "aws_region" { type = string }
variable "localstack_endpoint" { type = string }
variable "local_access_key" { type = string }
variable "local_secret_key" { type = string }
variable "node_catalog" {
  type = map(object({ subnet_index = number, security_groups = set(string), instance_type = string }))
}
