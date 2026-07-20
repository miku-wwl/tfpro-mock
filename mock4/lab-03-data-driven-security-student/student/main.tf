resource "aws_vpc_security_group_ingress_rule" "catalogue" {
  for_each = local.rules_by_key

  security_group_id = each.value.destination == "control" ? "sg-0123456789abcdef0" : data.aws_security_group.selected[each.value.destination].id

  cidr_ipv4                    = each.value.source == "-" ? lookup(local.subnet_cidrs, each.value.source_selector, "0.0.0.0/0") : each.value.source
  referenced_security_group_id = each.value.source == "-" ? null : data.aws_security_group.selected[each.value.source].id

  from_port   = each.value.protocol == "-1" ? "" : each.value.from_port
  to_port     = each.value.protocol == "-1" ? "" : each.value.to_port
  ip_protocol = each.value.protocol
  description = each.value.description
}
