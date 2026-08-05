resource "aws_security_group" "sg" {
  for_each = toset(["app-1-sg", "app-2-sg"])

  vpc_id = "vpc-598d13bace9383997"
}

locals {
  sg_csv         = csvdecode(file("${path.module}/sg.csv"))
  sg_csv_ingress = { for k, v in local.sg_csv : k => v if v.direction == "in" && v.description == "app-1" }
  sg_csv_egress  = { for k, v in local.sg_csv : k => v if v.direction == "out" && v.description == "app-2" }
}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  for_each = local.sg_csv_ingress

  security_group_id = aws_security_group.sg["app-1-sg"].id
  cidr_ipv4         = each.value.cidr_block
  from_port         = each.value.port
  ip_protocol       = each.value.protocol
  to_port           = each.value.port
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  for_each = local.sg_csv_egress

  security_group_id = aws_security_group.sg["app-2-sg"].id
  cidr_ipv4         = each.value.cidr_block
  from_port         = each.value.port
  ip_protocol       = each.value.protocol
  to_port           = each.value.port
}