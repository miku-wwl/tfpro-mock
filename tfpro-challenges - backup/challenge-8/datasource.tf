data "aws_subnets" "selected" {
  filter {
    name   = "tag:Name"
    values = ["app-subnet", "central-subnet", "database-subnet"]
  }
}

output "subnet_ids" {
  value = data.aws_subnets.selected.ids
}


data "aws_subnet" "app" {
  filter {
    name   = "tag:Name"
    values = ["app-subnet"]
  }
}

data "aws_subnet" "central" {
  filter {
    name   = "tag:Name"
    values = ["central-subnet"]
  }
}

data "aws_subnet" "database" {
  filter {
    name   = "tag:Name"
    values = ["database-subnet"]
  }
}