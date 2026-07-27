output "vpc_id" {
  value = aws_vpc.relay_fabric.id
}

output "subnet_ids" {
  value = aws_subnet.relay_segment[*].id
}
