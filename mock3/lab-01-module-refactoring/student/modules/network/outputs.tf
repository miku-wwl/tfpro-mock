output "vpc_id" {
  value = aws_vpc.core.id
}

output "subnet_ids" {
  value = aws_subnet.slice[*].id
}

output "subnet_ids_by_zone" {
  value = {
    for index, subnet in aws_subnet.slice :
    var.availability_zones[index] => subnet.id
  }
}
