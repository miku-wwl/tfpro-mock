output "vpc_id" { value = aws_vpc.platform.id }

# Draft defect: the required final output is map(string), not a positional list.
output "subnet_ids" {
  value = [for subnet in aws_subnet.segment : subnet.id]
}
