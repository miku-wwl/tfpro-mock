output "security_group_ids" {
  value = { for key, group in aws_security_group.boundary : key => group.id }
}

output "security_group_rule_ids" {
  value = merge(
    { for key, rule in aws_vpc_security_group_ingress_rule.cidr : "cidr:${key}" => rule.id },
    { for key, rule in aws_vpc_security_group_ingress_rule.peer : "peer:${key}" => rule.id },
    { for key, rule in aws_vpc_security_group_egress_rule.all : "egress:${key}" => rule.id }
  )
}
