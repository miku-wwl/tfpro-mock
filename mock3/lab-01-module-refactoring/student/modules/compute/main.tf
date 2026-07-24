resource "aws_instance" "workload" {
  provider = aws.workload
  for_each = var.workloads

  ami                    = var.ami
  instance_type          = each.value.instance_type
  subnet_id              = var.subnet_ids[each.value.subnet_index]
  vpc_security_group_ids = [for tier in each.value.security_tiers : var.security_group_ids[tier]]
  iam_instance_profile   = var.instance_profile_name

  tags = merge(var.common_tags, {
    Name            = "${var.name_prefix}-${each.key}"
    ObserverAccount = var.account_id
  })
}
