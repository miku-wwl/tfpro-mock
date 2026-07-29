locals {
  csv_rules = csvdecode(file("${path.module}/sg.csv"))

  subnet_cidr_blocks = {
    app          = data.aws_subnet.subnets["app-subnet"].cidr_block
    database     = data.aws_subnet.subnets["database-subnet"].cidr_block
    monitoring   = data.aws_subnet.subnets["central-subnet"].cidr_block
    "anti-virus" = data.aws_subnet.subnets["central-subnet"].cidr_block
  }

  ingress_rules = [
    for rule in local.csv_rules : {
      cidr_block = local.subnet_cidr_blocks[rule.cidr_block]
      from_port  = tonumber(split("-", rule.port)[0])
      to_port    = tonumber(try(split("-", rule.port)[1], split("-", rule.port)[0]))
      protocol   = rule.protocol
    }
    if rule.direction == "in"
  ]
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = {
    for index, rule in local.ingress_rules : index => rule
  }

  security_group_id = aws_security_group.kplabs.id
  cidr_ipv4         = each.value.cidr_block
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
}
