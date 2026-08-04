data "aws_subnets" "example" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.main.id]
  }

  filter {
    name   = "tag:Name"
    values = ["subnet-subnet1", "subnet-subnet2"]
  }
}

output "subnet_ids" {
  value = data.aws_subnets.example.ids
}
