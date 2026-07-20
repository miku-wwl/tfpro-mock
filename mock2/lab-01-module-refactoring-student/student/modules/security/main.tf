resource "aws_security_group" "tier" {
  for_each = var.groups

  name        = "${var.name_seed}-${each.key}"
  description = each.value.description
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.name_seed}-${each.key}"
    TierKey = each.key
    Lab     = "tfpro-state-addresses"
  }

  lifecycle {
    prevent_destroy = true
  }
}

module "rule_set" {
  source = "./rule-set"

  group_ids = { for key, group in aws_security_group.tier : key => group.id }
  rules     = var.rules
}
