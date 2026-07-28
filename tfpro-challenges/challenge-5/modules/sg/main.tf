variable "vpc_id" { type = string }
variable "rules" { type = any }

resource "aws_security_group" "challenge_5" {
  for_each = toset(["app-1-sg", "app-2-sg"])
  name     = each.value
  vpc_id   = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "app_1" {
  for_each          = var.rules.ingress
  security_group_id = aws_security_group.challenge_5["app-1-sg"].id
  cidr_ipv4         = each.value.cidr_block
  from_port         = tonumber(each.value.port)
  ip_protocol       = each.value.protocol
  to_port           = tonumber(each.value.port)
}

resource "aws_vpc_security_group_egress_rule" "app_2" {
  for_each          = var.rules.egress
  security_group_id = aws_security_group.challenge_5["app-2-sg"].id
  cidr_ipv4         = each.value.cidr_block
  from_port         = tonumber(each.value.port)
  ip_protocol       = each.value.protocol
  to_port           = tonumber(each.value.port)
}
