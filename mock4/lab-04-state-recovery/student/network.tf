resource "aws_security_group" "application" {
  name        = "${var.lab_prefix}-app-edge"
  description = "Incorrect starter description"
  vpc_id      = local.baseline.security_group.vpc_id

  tags = {
    Name        = "${var.lab_prefix}-app-edge"
    Environment = "exam"
  }
}

resource "aws_vpc_security_group_ingress_rule" "inbound" {
  for_each = local.active_rule_specs

  security_group_id = aws_security_group.application.id
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.ip_protocol
  cidr_ipv4         = each.value.cidr_ipv4
}
