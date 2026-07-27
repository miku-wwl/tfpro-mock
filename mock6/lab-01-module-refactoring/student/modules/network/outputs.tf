output "vpc_id" {
  value = aws_vpc.relay_fabric.id
}

output "subnet_ids" {
  value = {
    for index, subnet in aws_subnet.relay_segment : tostring(index) => subnet.id
  }
}
