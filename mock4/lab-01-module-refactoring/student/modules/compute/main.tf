resource "aws_instance" "executor" {
  for_each = var.instances

  ami                    = var.ami_id
  instance_type          = each.value.instance_type
  # Deliberate defect: the declared attribute is subnet_key, not subnet.
  subnet_id              = var.subnet_ids[each.value.subnet]
  vpc_security_group_ids = [var.security_group_ids["services"]]
  iam_instance_profile   = var.instance_profile

  tags = {
    Name = "${var.name_prefix}-${each.key}"
    # Deliberate defect: conditional branches return incompatible value types.
    Description = each.value.description == null ? "" : { value = each.value.description }
  }
}
