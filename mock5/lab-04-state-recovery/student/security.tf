resource "aws_security_group" "application" {
  name        = var.security_group_name
  description = "candidate application security group"
  vpc_id      = var.vpc_id

  tags = {
    Lab  = "lab-04-state-recovery"
    Role = "app"
  }
}

locals {
  ingress_rules = {
    "admin-console" = {
      cidr        = "203.0.113.0/24"
      description = "administration console"
      from_port   = 9443
      to_port     = 9443
    }
    "service-http" = {
      cidr        = "10.84.0.0/16"
      description = "internal service HTTP"
      from_port   = 8080
      to_port     = 8080
    }
  }
}

resource "aws_vpc_security_group_ingress_rule" "application" {
  for_each = local.ingress_rules

  security_group_id = aws_security_group.application.id
  cidr_ipv4         = each.value.cidr
  description       = each.value.description
  from_port         = each.value.from_port
  ip_protocol       = "tcp"
  to_port           = each.value.to_port
}
