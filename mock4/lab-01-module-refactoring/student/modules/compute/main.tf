resource "aws_instance" "executor" {
  for_each = var.instances

  ami                    = var.ami_id
  instance_type          = each.value.instance_type
  subnet_id              = var.subnet_ids[each.value.subnet_key]
  vpc_security_group_ids = [var.security_group_ids["services"]]
  iam_instance_profile   = var.instance_profile

  tags = merge(
    {
      Name     = "${var.name_prefix}-${each.key}"
      Priority = tostring(each.value.priority)
    },
    each.value.description == null ? {} : {
      Description = each.value.description
    },
    each.value.team == null ? {} : {
      Team = each.value.team
    },
    each.value.tags,
  )
}
