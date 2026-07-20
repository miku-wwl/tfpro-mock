locals {
  csv_rules  = csvdecode(file("${path.module}/data/rules.csv"))
  json_rules = jsondecode(file("${path.module}/data/rules.json"))
  yaml_rules = yamldecode(file("${path.module}/data/rules.yaml"))

  # STARTER DEFECTS ARE INTENTIONAL. Repair this without duplicating resource code.
  selected_rules = (
    var.rules_format == "csv" ? local.csv_rules :
    var.rules_format == "json" ? local.json_rules :
    local.yaml_rules
  )

  normalized_rules = [
    for index, rule in local.selected_rules : {
      input_index     = index
      direction       = lower(rule.direction)
      source          = rule.source
      destination     = rule.destination
      from_port       = rule.from_port
      to_port         = trimspace(tostring(rule.to_port)) == "" ? "" : tonumber(rule.to_port)
      protocol        = lower(tostring(rule.protocol))
      source_selector = rule.source_seletor
      description     = rule.description
      enabled         = rule.enabled
      source_value    = rule.source == "-" ? [rule.source_selector] : rule.source
    }
  ]

  # This key is too small and collides for the two operations:8082 rows.
  rules_by_destination_port = {
    for rule in local.normalized_rules :
    "${rule.destination}:${rule.from_port}" => rule
  }

  # This map avoids the duplicate only by binding addresses to input order.
  indexed_rules = {
    for index, rule in local.normalized_rules : tostring(index) => rule
  }

  security_group_ids = {
    frontend   = data.aws_security_group.frontend.id
    datastore  = data.aws_security_group.datastore.id
    operations = "sg-0123456789abcdef0"
  }

  subnet_cidrs = {
    public         = "10.73.10.0/24"
    administration = data.aws_subnet.administration.cidr_block
  }

  source_type_set = toset([
    for rule in local.normalized_rules : rule.source == "-" ? "cidr" : "security_group"
  ])
}
