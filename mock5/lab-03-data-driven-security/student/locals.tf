locals {
  csv_rules  = csvdecode(file("${path.module}/data/rules.csv"))
  json_rules = jsondecode(file("${path.module}/data/rules.json"))
  yaml_rules = yamldecode(file("${path.module}/data/rules.yaml"))

  # STARTER DEFECTS ARE INTENTIONAL. Repair this without duplicating resource code.
  selected_rules = jsondecode(
    var.rules_format == "csv" ? jsonencode(local.csv_rules) :
    var.rules_format == "json" ? jsonencode(local.json_rules) :
    jsonencode(local.yaml_rules)
  )

  normalized_rules = [
    for rule in local.selected_rules : {
      direction       = lower(rule.direction)
      source          = lower(rule.source)
      destination     = lower(rule.destination)
      from_port       = try(tonumber(rule.from_port), null)
      to_port         = try(tonumber(rule.to_port), null)
      protocol        = lower(rule.protocol)
      source_selector = try(rule.source_selector, null) == null ? "" : lower(rule.source_selector)
      description     = rule.description
      enabled         = tobool(rule.enabled)
    }
  ]

  ingress_rules = [
    for rule in local.normalized_rules : rule
    if rule.direction == "ingress" && rule.enabled
  ]

  # This key is too small and collides for the two operations:8082 rows.
  rules_by_destination_port = {
    for rule in local.normalized_rules :
    "${rule.destination}:${rule.from_port}" => rule
  }

  # This map avoids the duplicate only by binding addresses to input order.
  indexed_rules = {
    for index, rule in local.ingress_rules : tostring(index) => rule
  }

  security_group_ids = {
    frontend   = data.aws_security_group.frontend.id
    datastore  = data.aws_security_group.datastore.id
    operations = data.aws_security_group.operations.id
  }

  subnet_cidrs = {
    public         = data.aws_subnet.public.cidr_block
    administration = data.aws_subnet.administration.cidr_block
  }

  source_type_set = toset([
    for rule in local.normalized_rules : rule.source == "-" ? "cidr" : "security_group"
  ])
}
