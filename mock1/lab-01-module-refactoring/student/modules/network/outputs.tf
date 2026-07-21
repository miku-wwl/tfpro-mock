output "vpc_id" {
  value = aws_vpc.harbor.id
}

output "subnet_ids" {
  value = { for k, v in aws_subnet.zones : k => v.id }
}
