resource "aws_vpc_security_group_ingress_rule" "managed" {
  for_each = local.indexed_rules

  security_group_id = local.security_group_ids[each.value.destination]

  # Both arguments are currently populated, and SG sources are incorrectly treated as CIDRs.
  cidr_ipv4                    = each.value.source == "-" ? local.subnet_cidrs[each.value.source_selector] : "0.0.0.0/0"
  referenced_security_group_id = lookup(local.security_group_ids, each.value.source, local.security_group_ids.frontend)

  from_port   = each.value.protocol == "-1" ? "" : each.value.from_port
  to_port     = each.value.protocol == "-1" ? "" : each.value.to_port
  ip_protocol = each.value.protocol
  description = each.value.description
}
