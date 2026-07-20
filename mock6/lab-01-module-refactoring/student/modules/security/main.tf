resource "aws_security_group" "boundary" {
  for_each = var.group_definitions

  name        = "${var.name_prefix}-${each.key}"
  description = each.value.description
  vpc_id      = var.vpc_id

  tags = merge(var.resource_tags, {
    Name     = "${var.name_prefix}-${each.key}"
    Boundary = each.key
  })
}
