resource "aws_instance" "nodes" {
  for_each = var.instances

  ami           = var.ami_id
  instance_type = each.value.instance_type

  subnet_id = var.subnet_ids[each.value.subnet_key]
  vpc_security_group_ids = [
    for group_key in each.value.security_group_keys :
    var.security_group_ids[group_key]
  ]

  iam_instance_profile = var.instance_profile_name
  tags                 = each.value.tags
}
