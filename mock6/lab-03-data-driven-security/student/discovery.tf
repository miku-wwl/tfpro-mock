locals {
  suite          = "tfpro-final-06"
  subnet_roles   = toset(["dmz", "admin"])
  security_roles = toset(["edge", "ledger", "control"])
}

data "aws_vpc" "substrate" {
  filter {
    name   = "tag:LabSuite"
    values = [local.suite]
  }

  filter {
    name   = "tag:LabInstance"
    values = [var.environment_suffix]
  }

  filter {
    name   = "tag:LabRole"
    values = ["substrate"]
  }
}

data "aws_subnet" "network" {
  for_each = local.subnet_roles

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.substrate.id]
  }

  filter {
    name   = "tag:LabInstance"
    values = [var.environment_suffix]
  }

  filter {
    name   = "tag:LabRole"
    values = [each.key]
  }
}

data "aws_security_group" "zone" {
  for_each = local.security_roles

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.substrate.id]
  }

  filter {
    name   = "tag:LabInstance"
    values = [var.environment_suffix]
  }

  filter {
    name   = "tag:LabRole"
    values = [each.key]
  }
}
