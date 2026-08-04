data "aws_subnets" "example" {
  filter {
    name   = "vpc_id"
    values = [aws_vpc.main.id]
  }
}

output "subnet_ids" {
  value = data.aws_subnets.example.ids
}
