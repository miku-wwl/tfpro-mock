resource "aws_vpc_security_group_ingress_rule" "catalogue" {
  for_each = local.rules_by_key

  security_group_id = data.aws_security_group.selected[each.value.destination].id

  cidr_ipv4                    = each.value.source == "-" ? data.aws_subnet.selected[each.value.source_selector].cidr_block : null
  referenced_security_group_id = each.value.source != "-" ? data.aws_security_group.selected[each.value.source].id : null

  ip_protocol = each.value.protocol
  from_port   = each.value.protocol == "-1" ? null : each.value.from_port
  to_port     = each.value.protocol == "-1" ? null : each.value.to_port
  description = each.value.description
}
