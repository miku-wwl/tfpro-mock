output "vpc_id" { value = aws_vpc.platform.id }

# Draft defect: the required final output is map(string), not a positional list.
output "subnet_ids" {
  value = {
    for index, definition in var.segment_definitions :
    definition.key => aws_subnet.segment[index].id
  }
}
