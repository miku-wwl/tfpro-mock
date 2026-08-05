data "aws_subnet" "app" {
  filter {
    name   = "tag:Name"
    values = ["app-subnet"]
  }
}

data "aws_subnet" "database" {
  filter {
    name   = "tag:Name"
    values = ["database-subnet"]
  }
}

data "aws_subnet" "central" {
  filter {
    name   = "tag:Name"
    values = ["central-subnet"]
  }
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = ["vpc-48613c299cc81f389"]
  }
}

output "subnet_ids" {
  value = data.aws_subnets.subnets.ids
}


resource "aws_security_group" "kplabs-sg" {
  name   = "kplabs-sg"
  vpc_id = "vpc-48613c299cc81f389"
}

locals {
  sg_csv = csvdecode(file("${path.module}/sg.csv"))
}

resource "aws_vpc_security_group_ingress_rule" "name" {
  count = length(local.sg_csv)

  security_group_id = aws_security_group.kplabs-sg.id
  cidr_ipv4         = local.sg_csv[count.index].cidr_block == "app" ? data.aws_subnet.app.cidr_block : local.sg_csv[count.index].cidr_block == "database" ? data.aws_subnet.database.cidr_block : data.aws_subnet.central.cidr_block
  from_port         = split("-", local.sg_csv[count.index].port)[0]
  ip_protocol       = local.sg_csv[count.index].protocol
  to_port           = length(split("-", local.sg_csv[count.index].port)) > 1 ? split("-", local.sg_csv[count.index].port)[1] : split("-", local.sg_csv[count.index].port)[0]
}

output "filtered_data" {
  value = {
    for k, v in local.sg_csv : k => {
      cidr_block = aws_vpc_security_group_ingress_rule.name[k].cidr_ipv4
      from_port  = aws_vpc_security_group_ingress_rule.name[k].from_port
      to_port    = aws_vpc_security_group_ingress_rule.name[k].to_port
    }
  }
}