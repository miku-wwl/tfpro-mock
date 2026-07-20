output "vpc_id" {
  value = aws_vpc.fabric.id
}

output "subnet_ids_by_key" {
  value = aws_subnet.segment[*].id
}
