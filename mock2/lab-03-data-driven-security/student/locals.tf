locals {
  data_dir = "${path.module}/data"

  raw_rules = (
    var.rules_format == "csv"
    ? csvdecode(file("${local.data_dir}/rules.csv"))
    : var.rules_format == "json"
    ? jsondecode(file("${local.data_dir}/rules.json"))
    : yamldecode(file("${local.data_dir}/rules.yaml"))
  )

  normalized_rules = [
    for index, rule in local.raw_rules : {
      direction        = lower(rule.direction)
      source           = rule.source
      destination      = rule.destination
      from_port        = try(tonumber(rule.from_port), null)
      to_port          = try(tonumber(rule.to_port), null)
      protocol         = lower(rule.protocol)
      source_selector  = rule.source_selector
      description      = rule.description
      enabled          = tobool(rule.enabled)
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
