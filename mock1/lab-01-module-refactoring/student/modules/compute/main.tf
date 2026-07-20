resource "aws_instance" "nodes" {
  for_each = var.instances

  ami           = var.ami_id
  instance_type = each.value.instance_type

  # Draft contract issues: subnet_ids is a map and security_group_ids is a set.
  subnet_id              = var.subnet_ids[each.value.subnet_index]
  vpc_security_group_ids = [var.security_group_ids[0]]
  iam_instance_profile   = var.instance_profile_name
  tags                   = each.value.tags
}
