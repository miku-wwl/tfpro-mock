locals {
  sg_csv = csvdecode(file("${path.module}/sg.csv"))
}

resource "aws_security_group" "sg" {
  for_each = toset(["app-1-sg", "app-2-sg"])

  name   = each.value
  vpc_id = aws_vpc.main.id
}

output "temp" {
  value = {
    for k, v in local.sg_csv : "${v.name}-${v.direction}-${v.protocol}-${v.cidr_block}-${v.description}-${v.port}" => v if v.description == "app-1" && v.direction == "in"
  }
}

resource "aws_vpc_security_group_ingress_rule" "name" {
  for_each = {
    for k, v in local.sg_csv : "${v.name}-${v.direction}-${v.protocol}-${v.cidr_block}-${v.description}-${v.port}" => v if v.description == "app-1" && v.direction == "in"
  }

  security_group_id = aws_security_group.sg["app-1-sg"].id

  cidr_ipv4   = each.value.cidr_block
  from_port   = each.value.port
  ip_protocol = each.value.protocol
  to_port     = each.value.port
}

resource "aws_vpc_security_group_egress_rule" "name" {
  for_each = {
    for k, v in local.sg_csv : "${v.name}-${v.direction}-${v.protocol}-${v.cidr_block}-${v.description}-${v.port}" => v if v.description == "app-2" && v.direction == "out"
  }

  security_group_id = aws_security_group.sg["app-2-sg"].id

  cidr_ipv4   = each.value.cidr_block
  from_port   = each.value.port
  ip_protocol = each.value.protocol
  to_port     = each.value.port
}