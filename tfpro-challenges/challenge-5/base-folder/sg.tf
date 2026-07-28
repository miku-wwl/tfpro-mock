resource "aws_security_group" "challenge_5" {
  for_each = toset(["app-1-sg", "app-2-sg"])

  name   = each.value
  vpc_id = data.aws_vpc.challenge_5.id
}

locals {
  sg_rules = csvdecode(file("${path.module}/sg.csv"))

  app_1_ingress = {
    for index, rule in local.sg_rules : index => rule
    if rule.description == "app-1" && rule.direction == "in"
  }

  app_2_egress = {
    for index, rule in local.sg_rules : index => rule
    if rule.description == "app-2" && rule.direction == "out"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_1" {
  for_each = local.app_1_ingress

  security_group_id = aws_security_group.challenge_5["app-1-sg"].id
  cidr_ipv4         = each.value.cidr_block
  from_port         = tonumber(each.value.port)
  ip_protocol       = each.value.protocol
  to_port           = tonumber(each.value.port)
}

resource "aws_vpc_security_group_egress_rule" "app_2" {
  for_each = local.app_2_egress

  security_group_id = aws_security_group.challenge_5["app-2-sg"].id
  cidr_ipv4         = each.value.cidr_block
  from_port         = tonumber(each.value.port)
  ip_protocol       = each.value.protocol
  to_port           = tonumber(each.value.port)
}
