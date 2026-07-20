resource "aws_security_group" "boundary" {
  for_each = var.groups

  name        = "${var.name_prefix}-${each.key}"
  description = each.value.description
  vpc_id      = var.vpc_id
}
