locals {
  raw_rules = var.rules_format == "csv" ? csvdecode(file("${path.module}/data/rules.csv")) : (
    var.rules_format == "json" ? jsondecode(file("${path.module}/data/rules.json")) : yamldecode(file("${path.module}/data/rules.yaml"))
  )

  normalized_rules = [
    for rule in local.raw_rules : {
      direction       = lower(rule.direction)
      source          = rule.source
      destination     = rule.destination
      from_port       = try(tonumber(rule.from_port), null)
      to_port         = try(tonumber(rule.to_port), null)
      protocol        = lower(rule.protocol)
      source_selector = rule.source_selector
      description     = rule.description
      enabled         = tobool(rule.enabled)
    }
  ]

  ingress_rules = [
    for rule in local.normalized_rules : rule
    if rule.direction == "ingress" && rule.enabled
  ]

  stable_rule_map = {
    for rule in local.ingress_rules :
    jsonencode([
      rule.source,
      rule.destination,
      rule.protocol,
      rule.from_port,
      rule.to_port
    ]) => rule
  }

  rule_key_set = toset(keys(local.stable_rule_map))
}

module "inventory" {
  source = "./modules/inventory"
  lab_id = var.lab_id

  providers = {
    aws.readonly = aws.readonly
    aws.audit    = aws.audit
  }
}

module "rule_engine" {
  source = "./modules/rule-engine"

  providers = {
    aws.rules = aws.rules
  }

  rules              = local.stable_rule_map
  security_group_ids = module.inventory.security_group_ids
  subnet_cidrs       = module.inventory.subnet_cidrs
  account_id         = module.inventory.caller_account_id
}
