resource "aws_security_group" "tiers" {
  for_each = var.security_groups

  name        = each.value.name
  description = each.value.description
  vpc_id      = var.vpc_id
  tags        = each.value.tags
}

resource "aws_vpc_security_group_ingress_rule" "links" {
  for_each = var.ingress_rules

  security_group_id            = aws_security_group.tiers[each.value.target_group].id
  referenced_security_group_id = each.value.source_group == null ? null : aws_security_group.tiers[each.value.source_group].id
  cidr_ipv4                    = each.value.source_group == null ? each.value.source_cidr : null
  from_port                    = each.value.port
  to_port                      = each.value.port
  ip_protocol                  = each.value.protocol
  description                  = each.value.description
  tags                         = each.value.tags
}
