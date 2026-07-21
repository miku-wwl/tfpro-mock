resource "aws_vpc_security_group_ingress_rule" "policy" {
  for_each = local.ingress_rule_map

  security_group_id = local.security_group_ids[each.value.destination]
  ip_protocol       = each.value.protocol

  cidr_ipv4 = (
    each.value.source == "-" ?
    local.subnet_cidrs[each.value.source_selector] :
    null
  )

  referenced_security_group_id = (
    each.value.source == "-" ?
    null :
    local.security_group_ids[each.value.source]
  )

  from_port = each.value.protocol == "-1" ? null : each.value.from_port
  to_port   = each.value.protocol == "-1" ? null : each.value.to_port

  description = each.value.description
}
