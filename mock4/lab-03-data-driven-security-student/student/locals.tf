locals {
  selected_rules = (
    var.rules_format == "csv"
    ? csvdecode(file("${path.module}/data/rules.csv"))
    : var.rules_format == "json"
    ? jsondecode(file("${path.module}/data/rules.json"))
    : yamldecode(file("${path.module}/data/rules.yaml"))
  )

  normalized_rules = [
    for index, rule in local.selected_rules : {
      direction       = lower(rule.direction)
      source          = lower(rule.source)
      destination     = lower(rule.destination)
      from_port       = try(tonumber(rule.from_port), null)
      to_port         = try(tonumber(rule.to_port), null)
      protocol        = lower(rule.protocol)
      source_selector = coalesce(rule.source_selector, "") == "" ? null : rule.source_selector
      description     = rule.description
      enabled         = tobool(rule.enabled)
    }
  ]

  ingress_rules = [
    for rule in local.normalized_rules : rule
    if rule.direction == "ingress" && rule.enabled
  ]

  rules_by_key = {
    for rule in local.ingress_rules : jsonencode({
      source          = rule.source
      destination     = rule.destination
      protocol        = rule.protocol
      from_port       = rule.from_port
      to_port         = rule.to_port
      source_selector = rule.source_selector
    }) => rule
  }

  subnet_cidrs = {
    for role, subnet in data.aws_subnet.selected : role => subnet.cidr_block
  }

  protocol_set = toset([for rule in local.normalized_rules : rule.protocol])
}
