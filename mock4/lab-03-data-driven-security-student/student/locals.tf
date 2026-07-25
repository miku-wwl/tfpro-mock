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
      row_key         = tostring(index)
    }
  ]

  ingress_rules = [
    for rule in local.normalized_rules : rule
    if rule.direction == "ingress" && rule.enabled
  ]

  # This key is incomplete and input-position data is treated as persistent identity.
  rules_by_key = {
    for index, rule in local.ingress_rules :
    "${rule.destination}:${rule.from_port}" => merge(rule, { permanent_key = tostring(index) })
  }

  subnet_cidrs = {
    public         = data.aws_subnet.selected["public"].cidr_block
    administration = "10.42.90.0/24"
  }

  protocol_set = toset([for rule in local.normalized_rules : rule.protocol])
}
