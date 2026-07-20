data "aws_vpc" "practice" {
  filter {
    name   = "tag:Lab"
    values = ["tfpro-lab03"]
  }

  filter {
    name   = "tag:Component"
    values = ["network"]
  }
}

data "aws_subnet" "segment" {
  for_each = toset(["public", "administration"])

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.practice.id]
  }

  filter {
    name   = "tag:SubnetRole"
    values = [each.key]
  }
}

data "aws_security_group" "workload" {
  for_each = toset(["edge", "records", "control"])

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.practice.id]
  }

  filter {
    name   = "tag:SecurityRole"
    values = [each.key]
  }
}
