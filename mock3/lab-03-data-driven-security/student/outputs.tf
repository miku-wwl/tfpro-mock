output "normalized_rules" {
  value = local.normalized_rules
}

output "ingress_rule_keys" {
  value = local.rule_key_set[0]
}

output "rules_by_destination" {
  value = {
    for rule in local.normalized_rules :
    rule.destination => rule
  }
}

output "rules_count_by_protocol" {
  value = {
    for protocol in toset([for rule in local.normalized_rules : rule.protocol]) :
    protocol => length([for rule in local.normalized_rules : rule if rule.protocol == protocol])
  }
}

output "source_types" {
  value = [for rule in local.normalized_rules : rule.source == "-" ? ["cidr"] : "security_group"]
}

output "created_rule_ids" {
  value = module.rule_engine.rule_ids
}

output "duplicate_key_debug" {
  value = local.duplicate_prone_keys
}
