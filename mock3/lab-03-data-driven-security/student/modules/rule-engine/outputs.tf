output "rule_ids" {
  value = { for key, rule in aws_vpc_security_group_ingress_rule.this : key => rule.id }
}
