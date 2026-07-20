output "security_group_ids" {
  value = values(aws_security_group.boundary)[*].id
}
