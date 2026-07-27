resource "aws_security_group" "boundary" {
  for_each = var.group_definitions

  name        = "${var.name_prefix}-${each.key}"
  description = each.value.description
  vpc_id      = var.vpc_id

  tags = merge(var.resource_tags, {
    Name     = "${var.name_prefix}-${each.key}"
    Boundary = each.key
  })
}

resource "aws_vpc_security_group_ingress_rule" "edge_tls" {
  security_group_id = aws_security_group.boundary["edge"].id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  description       = "Public TLS traffic"
}

resource "aws_vpc_security_group_ingress_rule" "service_from_edge" {
  security_group_id            = aws_security_group.boundary["service"].id
  referenced_security_group_id = aws_security_group.boundary["edge"].id
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080
  description                  = "Relay traffic from the edge boundary"
}

resource "aws_vpc_security_group_ingress_rule" "operations_ssh" {
  for_each          = var.operator_cidrs
  security_group_id = aws_security_group.boundary["operations"].id
  cidr_ipv4         = each.value
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  description       = "Operator access"
}

resource "aws_vpc_security_group_ingress_rule" "service_metrics" {
  security_group_id            = aws_security_group.boundary["service"].id
  referenced_security_group_id = aws_security_group.boundary["operations"].id
  from_port                    = 9090
  ip_protocol                  = "tcp"
  to_port                      = 9090
  description                  = "Metrics collection from operations"
}

resource "aws_vpc_security_group_egress_rule" "edge_to_service" {
  security_group_id            = aws_security_group.boundary["edge"].id
  referenced_security_group_id = aws_security_group.boundary["service"].id
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080
  description                  = "Forward relay traffic to processing"
}

resource "aws_vpc_security_group_egress_rule" "service_outbound" {
  security_group_id = aws_security_group.boundary["service"].id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Service outbound access"
}
