output "vpc_id" {
  value = aws_vpc.fabric.id
}

output "subnet_ids" {
  value = [for subnet in aws_subnet.segment : subnet.id]
}
