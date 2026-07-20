resource "aws_security_group" "tier" {
  for_each = var.security_tiers

  name        = "${var.name_stem}-${each.key}"
  description = each.value.description
  vpc_id      = var.vpc_id[0]
  tags = {
    Name = "${var.name_stem}-${each.key}"
    Tier = each.key
  }
}

resource "aws_vpc_security_group_ingress_rule" "path" {
  for_each = var.ingress_rules

  security_group_id            = aws_security_group.tier[each.value.target_tier].id
  cidr_ipv4                    = try(each.value.source_cidr, null)
  referenced_security_group_id = try(aws_security_group.tier[each.value.source_tier].id, null)
  from_port                    = each.value.port
  to_port                      = each.value.port
  ip_protocol                  = each.value.protocol
  description                  = each.value.description
}
