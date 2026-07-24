resource "aws_vpc_security_group_ingress_rule" "this" {
  provider = aws.rules
  for_each = var.rules

  security_group_id = var.security_group_ids[each.value.destination]

  cidr_ipv4 = each.value.source == "-" ? var.subnet_cidrs[each.value.source_selector] : null

  referenced_security_group_id = each.value.source != "-" ? var.security_group_ids[each.value.source] : null

  ip_protocol = each.value.protocol
  from_port   = each.value.protocol == "-1" ? null : each.value.from_port
  to_port     = each.value.protocol == "-1" ? null : each.value.to_port
  description = "account=${var.account_id} | ${each.value.description}"
}
