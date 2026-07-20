resource "aws_vpc_security_group_ingress_rule" "path" {
  for_each = var.rules

  security_group_id            = var.group_ids[each.value.destination]
  referenced_security_group_id = each.value.source == null ? null : var.group_ids[each.value.source]
  cidr_ipv4                     = each.value.source == null ? each.value.cidr : null
  from_port                     = each.value.from_port
  to_port                       = each.value.to_port
  ip_protocol                   = each.value.protocol
  description                   = each.value.description

  tags = {
    Name = each.key
    Lab  = "tfpro-state-addresses"
  }

  lifecycle {
    prevent_destroy = true
  }
}
