output "normalized_rules" {
  value = local.normalized_rules
}

output "ingress_rule_keys" {
  value = sort(keys(local.ingress_rule_map))
}

output "rules_by_destination" {
  value = {}
}

output "rules_count_by_protocol" {
  value = {}
}

output "source_types" {
  value = {}
}

output "created_rule_ids" {
  value = {}
}
