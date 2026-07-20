locals {
  # Intentionally defective starter: repair the data selection and type handling.
  selected_rules = var.rules_format == "csv" ? csvdecode(file("${path.module}/data/rules.csv")) : var.rules_format == "json" ? jsondecode(file("${path.module}/data/rules.json")) : yamldecode(file("${path.module}/data/rules.yaml"))

  normalized_rules = [
    for index, rule in local.selected_rules : {
      direction       = lower(rule.direction)
      source          = rule.source
      destination     = rule.destination
      from_port       = rule.from_port
      to_port         = rule.to_port
      protocol        = rule.protocol
      source_selector = try(rule.source_seletor, "")
      description     = rule.description
      enabled         = rule.enabled
      source_probe    = rule.source == "-" ? [rule.source_selector] : rule.source
      row_key         = tostring(index)
    }
  ]

  # This key is incomplete and input-position data is treated as persistent identity.
  rules_by_key = {
    for index, rule in local.normalized_rules :
    "${rule.destination}:${rule.from_port}" => merge(rule, { permanent_key = tostring(index) })
  }

  subnet_cidrs = {
    public         = data.aws_subnet.selected["public"].cidr_block
    administration = "10.42.90.0/24"
  }

  protocol_set = toset([for rule in local.normalized_rules : rule.protocol])
}
