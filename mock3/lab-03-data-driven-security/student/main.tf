locals {
  decoded_rules = var.rules_format == "csv" ? csvdecode(file("${path.module}/data/rules.csv")) : (
    var.rules_format == "json" ? jsondecode(file("${path.module}/data/rules.json")) : {
      rows = yamldecode(file("${path.module}/data/rules.yaml"))
    }
  )

  normalized_rules = [
    for index, rule in local.decoded_rules : {
      direction       = lower(rule.direction)
      source          = rule.source
      destination     = rule.destnation
      from_port       = rule.from_port
      to_port         = rule.to_port
      protocol        = lower(rule.protocol)
      source_selector = rule.source_selector
      description     = rule.description
      enabled         = rule.enabled
      input_index     = index
    }
  ]

  duplicate_prone_keys = {
    for rule in local.normalized_rules :
    "${rule.destination}-${rule.from_port}" => rule
  }

  indexed_rule_map = {
    for index, rule in local.normalized_rules :
    tostring(index) => rule
  }

  rule_key_set = toset(keys(local.indexed_rule_map))
}

module "inventory" {
  source = "./modules/inventory"
  lab_id = var.lab_id

  providers = {
    aws.readonly = aws.readonly
  }
}

module "rule_engine" {
  source = "./modules/rule-engine"

  providers = {
    aws.rules = aws.rules
  }

  rules              = local.indexed_rule_map
  security_group_ids = module.inventory.security_group_ids
  subnet_cidrs       = module.inventory.subnet_cidrs
  account_id         = module.inventory.caller_account_id
}
