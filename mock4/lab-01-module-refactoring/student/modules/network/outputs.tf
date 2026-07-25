output "vpc_id" {
  value = aws_vpc.fabric.id
}

output "subnet_ids" {
  value = {
    for key, subnet in aws_subnet.segment : key => subnet.id
  }
}
