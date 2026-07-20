output "security_group_ids" {
  value = { for key, group in aws_security_group.tier : key => group.id }
}
