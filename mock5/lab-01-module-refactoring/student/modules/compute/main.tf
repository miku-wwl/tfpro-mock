resource "aws_instance" "node" {
  for_each = var.workload_roles

  ami                    = var.base_ami
  instance_type          = each.value.instance_type
  subnet_id              = var.subnet_ids[each.value.segment_key]
  vpc_security_group_ids = [var.security_group_ids[each.value.security_tier]]
  iam_instance_profile   = var.instance_profile_name

  tags = {
    Name = "${var.name_stem}-${var.shared_name_token}-${each.key}"
    Role = each.key
  }
}
