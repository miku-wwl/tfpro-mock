locals {
  # The outer JSON round-trip keeps the decoder result dynamically typed.
  # The selected records still need correct normalization below.
  raw_rules = jsondecode(
    var.rules_format == "csv" ? jsonencode(csvdecode(file("${path.module}/data/rules.csv"))) :
    var.rules_format == "json" ? jsonencode(jsondecode(file("${path.module}/data/rules.json"))) :
    jsonencode(yamldecode(file("${path.module}/data/rules.yaml")))
  )

  normalized_rules = [
    for rule in local.raw_rules : {
      direction       = lower(rule.direction)
      source          = lower(rule.source)
      destination     = lower(rule.destination)
      from_port       = try(tonumber(rule.from_port), null)
      to_port         = try(tonumber(rule.to_port), null)
      protocol        = lower(rule.protocol)
      source_selector = lower(rule.source_selector)
      description     = rule.description
      enabled         = tobool(rule.enabled)
    }
  ]

  ingress_rules = [
    for rule in local.normalized_rules : rule if rule.direction == "ingress" && rule.enabled
  ]

  ingress_rule_map = {
    for rule in local.ingress_rules :
    jsonencode([
      rule.source,
      rule.source_selector,
      rule.destination,
      rule.protocol,
      rule.from_port,
      rule.to_port,
    ]) => rule
  }
  subnet_cidrs = {
    dmz_net   = data.aws_subnet.segment["public"].cidr_block
    admin_net = data.aws_subnet.segment["administration"].cidr_block
  }

  security_group_ids = {
    for role, group in data.aws_security_group.workload : role => group.id
  }
}
