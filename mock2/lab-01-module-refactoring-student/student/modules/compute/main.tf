resource "aws_instance" "node" {
  for_each = var.nodes

  ami = var.ami_id

  instance_type = each.value.instance_size

  subnet_id = var.subnet_ids_by_key[each.value.subnet_key]
  vpc_security_group_ids = [
    for key in sort(tolist(each.value.security_group_keys)) : var.security_group_ids[key]
  ]
  iam_instance_profile = var.instance_profile_name

  tags = {
    Name    = "${var.name_seed}-${each.key}"
    NodeKey = each.key
    Lab     = "tfpro-state-addresses"
  }

  lifecycle {
    prevent_destroy = true
  }
}
