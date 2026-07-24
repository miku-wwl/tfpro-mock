output "normalized_rules" {
  value = local.normalized_rules
}

output "ingress_rule_keys" {
  value = sort(keys(local.stable_rule_map))
}

output "rules_by_destination" {
  value = {
    for rule in local.ingress_rules :
    rule.destination => rule...
  }
}

output "rules_count_by_protocol" {
  value = {
    for protocol in toset([for rule in local.ingress_rules : rule.protocol]) :
    protocol => length([for rule in local.ingress_rules : rule if rule.protocol == protocol])
  }
}

output "source_types" {
  value = toset([
    for rule in local.ingress_rules :
    rule.source == "-" ? "cidr" : "security_group"
  ])
}

output "created_rule_ids" {
  value = module.rule_engine.rule_ids
}
