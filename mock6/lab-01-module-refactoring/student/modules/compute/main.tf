resource "aws_instance" "relay_node" {
  for_each = var.nodes

  ami                    = var.ami_id
  instance_type          = each.value.instance_type
  subnet_id              = var.subnet_ids[each.value.subnet_key]
  vpc_security_group_ids = [for group_name in each.value.security_groups : var.security_group_ids[group_name]]
  iam_instance_profile   = var.instance_profile_name

  tags = merge(var.resource_tags, {
    Name = "${var.name_prefix}-${each.key}"
    Role = each.key
  })
}
