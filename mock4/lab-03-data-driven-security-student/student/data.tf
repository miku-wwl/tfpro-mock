data "aws_vpc" "practice" {
  tags = {
    Lab  = var.lab_tag
    Role = "network"
  }
}

data "aws_subnet" "selected" {
  for_each = toset(["public", "administration"])

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.practice.id]
  }

  filter {
    name   = "tag:Lab"
    values = [var.lab_tag]
  }

  filter {
    name   = "tag:Role"
    values = [each.key]
  }
}

data "aws_security_group" "selected" {
  for_each = toset(["edge", "ledger", "control"])

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.practice.id]
  }

  filter {
    name   = "tag:Lab"
    values = [var.lab_tag]
  }

  filter {
    name   = "tag:Role"
    values = [each.key]
  }
}
