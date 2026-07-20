output "security_group_ids" {
  value = { for key, group in aws_security_group.boundary : key => group.id }
}
