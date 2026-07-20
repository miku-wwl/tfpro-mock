resource "aws_security_group" "application" {
  name        = var.security_group_name
  description = "Application ingress boundary"
  vpc_id      = var.vpc_id

  tags = {
    Name = var.security_group_name
    Tier = "edge"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "client_https" {
  security_group_id = aws_security_group.application.id
  cidr_ipv4         = "10.84.10.0/24"
  description       = "client-access"
  from_port         = 8443
  ip_protocol       = "tcp"
  to_port           = 8443

  tags = {
    Name = "client-8443"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "operations_https" {
  security_group_id = aws_security_group.application.id
  cidr_ipv4         = "10.84.21.0/24"
  description       = "operations-access"
  from_port         = 8443
  ip_protocol       = "tcp"
  to_port           = 8443

  tags = {
    Name = "operations-8443"
  }

  lifecycle {
    prevent_destroy = true
  }
}
