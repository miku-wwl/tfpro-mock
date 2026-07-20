output "normalized_rules" {
  value = local.normalized_rules
}

output "ingress_rule_keys" {
  value = keys(aws_vpc_security_group_ingress_rule.catalogue)
}

output "rules_by_destination" {
  value = {
    for rule in local.normalized_rules : rule.destination => rule
  }
}

output "rules_count_by_protocol" {
  value = {
    for protocol in local.protocol_set : protocol => length([
      for rule in local.normalized_rules : rule if rule.protocol == protocol
    ])
  }
}

output "source_types" {
  value = local.protocol_set[0]
}

output "created_rule_ids" {
  value = {
    for key, rule in aws_vpc_security_group_ingress_rule.catalogue : key => rule.id
  }
}

output "unique_protocols" {
  value = local.protocol_set
}
