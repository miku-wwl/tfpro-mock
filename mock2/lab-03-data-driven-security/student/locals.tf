locals {
  raw_rules = var.rules_format == "csv" ? csvdecode(file("${path.module}/data/rules.csv")) : (
    var.rules_format == "json" ? jsondecode(file("${path.module}/data/rules.json")) : yamldecode(file("${path.module}/data/rules.yaml"))
  )

  normalized_rules = [
    for index, rule in local.raw_rules : {
      direction       = lower(rule.direction)
      source          = rule.source
      destination     = rule.destnation
      from_port       = rule.from_port
      to_port         = rule.to_port
      protocol        = lower(rule.protocol)
      source_selector = rule.source_selector
      description     = rule.description
      enabled         = rule.enabled
      source_reference = rule.source == "-" ? [rule.source_selector] : rule.source
      permanent_key    = "${index}-${rule.destination}-${rule.from_port}"
    }
  ]

  rules_by_key = {
    for index, rule in local.normalized_rules :
    "${rule.destination}-${rule.from_port}" => merge(rule, { input_position = index })
  }

  source_types = toset([
    for rule in local.normalized_rules : rule.source == "-" ? "cidr" : "security_group"
  ])
}
