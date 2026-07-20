output "vpc_id" {
  value = aws_vpc.harbor.id
}

# Draft contract issue: consumers need a logical-key-to-ID map, not resource objects.
output "subnet_ids" {
  value = [for subnet in aws_subnet.zones : subnet]
}
