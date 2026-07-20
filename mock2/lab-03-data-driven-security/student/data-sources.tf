data "aws_vpc" "lab" {
  filter {
    name   = "tag:Lab"
    values = ["tfpro-lab03"]
  }
}

data "aws_subnet" "selected" {
  for_each = toset(["public", "administration"])

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.lab.id]
  }

  filter {
    name   = "tag:Lab"
    values = ["tfpro-lab03"]
  }

  filter {
    name   = "tag:Role"
    values = [each.key]
  }
}

data "aws_security_group" "selected" {
  for_each = toset(["frontend", "datastore", "operations"])

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.lab.id]
  }

  filter {
    name   = "tag:Lab"
    values = ["tfpro-lab03"]
  }

  filter {
    name   = "tag:Role"
    values = [each.key]
  }
}
