resource "aws_security_group" "boundary" {
  for_each = var.groups

  name        = "${var.name_prefix}-${each.key}"
  description = each.value.description
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "cidr" {
  for_each = var.cidr_rules

  security_group_id = aws_security_group.boundary[each.value.destination].id
  cidr_ipv4         = each.value.cidr
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  description       = each.value.description
}

resource "aws_vpc_security_group_ingress_rule" "peer" {
  for_each = var.peer_rules

  security_group_id            = aws_security_group.boundary[each.value.destination].id
  referenced_security_group_id = aws_security_group.boundary[each.value.source].id
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.protocol
  description                  = each.value.description
}

resource "aws_vpc_security_group_egress_rule" "all" {
  for_each = aws_security_group.boundary

  security_group_id = each.value.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Unrestricted lab egress"
}
