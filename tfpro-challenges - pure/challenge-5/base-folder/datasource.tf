data "aws_subnets" "example" {
  filter {
    name   = "vpc-id"
    values = ["vpc-598d13bace9383997"]
  }
}



data "aws_subnet" "subnet1" {
  vpc_id = "vpc-598d13bace9383997"
  filter {
    name   = "tag:Name"
    values = ["subnet-subnet1"]
  }
}

data "aws_subnet" "subnet2" {
  vpc_id = "vpc-598d13bace9383997"
  filter {
    name   = "tag:Name"
    values = ["subnet-subnet2"]
  }
}

output "subnet_ids" {
  value = data.aws_subnets.example.ids
}

