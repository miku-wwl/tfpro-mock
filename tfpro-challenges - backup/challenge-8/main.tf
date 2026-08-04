resource "aws_security_group" "kplabs-sg" {
  name = "kplabs-sg"

  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = "vpc-bc30450b2ee2a410f"

  tags = {
    Name = "allow_tls"
  }
}

locals {
  sg    = csvdecode(file("${path.module}/sg.csv"))
  sg_in = [for k, v in local.sg : v if v.direction == "in"]
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  count = length(local.sg_in)

  security_group_id = aws_security_group.kplabs-sg.id

  cidr_ipv4 = local.sg_in[count.index].cidr_block == "app" ? data.aws_subnet.app.cidr_block : (
    local.sg_in[count.index].cidr_block == "database" ? data.aws_subnet.database.cidr_block : data.aws_subnet.central.cidr_block
  )
  from_port   = split("-", local.sg_in[count.index].port)[0]
  ip_protocol = local.sg_in[count.index].protocol
  to_port     = length(split("-", local.sg_in[count.index].port)) > 1 ? split("-", local.sg_in[count.index].port)[1] : split("-", local.sg_in[count.index].port)[0]
}

output "filtered_data" {
  value = { for k, v in aws_vpc_security_group_ingress_rule.allow_tls_ipv4 :
    k => {
      "cidr_block" = v.cidr_ipv4
      "from_port"  = v.from_port
      "to_port"    = v.to_port
    }
  }
}