data "aws_caller_identity" "observer" {
  provider = aws.readonly
}

resource "aws_security_group" "tier" {
  provider = aws.network
  for_each = var.security_tiers

  name        = "${var.name_prefix}-${each.key}"
  description = "${each.key} boundary for Terraform Professional practice"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-${each.key}"
    Tier = each.key
  })
}

resource "aws_vpc_security_group_ingress_rule" "public_tls" {
  provider = aws.network

  security_group_id = aws_security_group.tier["gateway"].id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Public TLS entry"
}

resource "aws_vpc_security_group_ingress_rule" "gateway_to_services" {
  provider = aws.network

  security_group_id            = aws_security_group.tier["services"].id
  referenced_security_group_id = aws_security_group.tier["gateway"].id
  from_port                    = 8443
  to_port                      = 8443
  ip_protocol                  = "tcp"
  description                  = "Gateway to services"
}

resource "aws_vpc_security_group_ingress_rule" "operations_to_services" {
  provider = aws.network

  security_group_id            = aws_security_group.tier["services"].id
  referenced_security_group_id = aws_security_group.tier["operations"].id
  from_port                    = 9090
  to_port                      = 9090
  ip_protocol                  = "tcp"
  description                  = "Operations metrics access"
}

resource "aws_vpc_security_group_ingress_rule" "operations_to_gateway" {
  provider = aws.network

  security_group_id            = aws_security_group.tier["gateway"].id
  referenced_security_group_id = aws_security_group.tier["operations"].id
  from_port                    = 2200
  to_port                      = 2200
  ip_protocol                  = "tcp"
  description                  = "Operations administrative access"
}

resource "aws_vpc_security_group_egress_rule" "outbound" {
  provider = aws.network
  for_each = var.security_tiers

  security_group_id = aws_security_group.tier[each.key].id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Explicit outbound access for ${each.key}"
}
