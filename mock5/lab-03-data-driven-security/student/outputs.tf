output "normalized_rules" {
  value = local.normalized_rules
}

output "ingress_rule_keys" {
  value = keys(local.rules_by_destination_port)
}

output "rules_by_destination" {
  value = {
    for rule in local.normalized_rules :
    rule.destination => rule...
  }
}

output "rules_count_by_protocol" {
  value = {
    for protocol in distinct([for rule in local.normalized_rules : rule.protocol]) :
    protocol => length([for rule in local.normalized_rules : rule if rule.protocol == protocol])
  }
}

output "source_types" {
  value = local.source_type_set[0]
}

output "created_rule_ids" {
  value = {
    for index, rule in aws_vpc_security_group_ingress_rule.managed : index => rule.id
  }
}
