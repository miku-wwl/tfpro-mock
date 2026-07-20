resource "aws_vpc_security_group_ingress_rule" "catalogue" {
  for_each = local.rules_by_key

  security_group_id = each.value.destination == "operations" ? "sg-0123456789abcdef0" : data.aws_security_group.selected[each.value.destination].id

  cidr_ipv4                   = each.value.source == "-" ? "10.73.10.0/24" : each.value.source
  referenced_security_group_id = data.aws_security_group.selected[each.value.source].id

  ip_protocol = each.value.protocol
  from_port   = each.value.protocol == "-1" ? "" : each.value.from_port
  to_port     = each.value.protocol == "-1" ? "" : each.value.to_port
  description = each.value.description
}
