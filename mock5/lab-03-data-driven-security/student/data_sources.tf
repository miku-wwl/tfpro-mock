data "aws_vpc" "practice" {
  filter {
    name   = "tag:LabId"
    values = ["tfpro-lab-03"]
  }

  filter {
    name   = "tag:ComponentRole"
    values = ["vpc"]
  }
}

data "aws_subnet" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.practice.id]
  }

  filter {
    name   = "tag:LabId"
    values = ["tfpro-lab-03"]
  }

  filter {
    name   = "tag:ComponentRole"
    values = ["public"]
  }
}

data "aws_subnet" "administration" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.practice.id]
  }

  filter {
    name   = "tag:LabId"
    values = ["tfpro-lab-03"]
  }

  filter {
    name   = "tag:ComponentRole"
    values = ["administration"]
  }
}

data "aws_security_group" "frontend" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.practice.id]
  }

  filter {
    name   = "tag:LabId"
    values = ["tfpro-lab-03"]
  }

  filter {
    name   = "tag:ComponentRole"
    values = ["frontend"]
  }
}

data "aws_security_group" "datastore" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.practice.id]
  }

  filter {
    name   = "tag:LabId"
    values = ["tfpro-lab-03"]
  }

  filter {
    name   = "tag:ComponentRole"
    values = ["datastore"]
  }
}

data "aws_security_group" "operations" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.practice.id]
  }

  filter {
    name   = "tag:LabId"
    values = ["tfpro-lab-03"]
  }

  filter {
    name   = "tag:ComponentRole"
    values = ["operations"]
  }
}
