output "normalized_rules" {
  value = local.normalized_rules
}

output "ingress_rule_keys" {
  value = keys(local.rules_by_key)
}

output "rules_by_destination" {
  value = {
    for rule in values(local.rules_by_key) : rule.destination => rule...
  }
}

output "rules_count_by_protocol" {
  value = {
    for protocol in distinct([
      for rule in values(local.rules_by_key) : rule.protocol
      ]) : protocol => length([
      for rule in values(local.rules_by_key) : rule if rule.protocol == protocol
    ])
  }
}

output "source_types" {
  value = local.source_types
}

output "created_rule_ids" {
  value = {
    for key, rule in aws_vpc_security_group_ingress_rule.catalogue : key => rule.id
  }
}
