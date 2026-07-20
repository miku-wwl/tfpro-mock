data "aws_vpc" "selected" {
  provider = aws.readonly

  filter {
    name   = "tag:LabId"
    values = [var.lab_id]
  }

  filter {
    name   = "tag:LogicalName"
    values = ["core"]
  }
}

data "aws_subnet" "selected" {
  provider = aws.readonly
  for_each = toset(["public", "administration"])

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:LabId"
    values = [var.lab_id]
  }

  filter {
    name   = "tag:LogicalName"
    values = [each.key]
  }
}

data "aws_security_group" "selected" {
  provider = aws.readonly
  for_each = toset(["frontend", "datastore", "operations"])

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:LabId"
    values = [var.lab_id]
  }

  filter {
    name   = "tag:LogicalName"
    values = [each.key]
  }
}

data "aws_caller_identity" "audit" {
  provider = aws.audit
}
