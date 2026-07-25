output "normalized_rules" {
  value = local.normalized_rule_map
}

output "ingress_rule_keys" {
  value = keys(aws_vpc_security_group_ingress_rule.catalogue)
}

output "rules_by_destination" {
  value = {
    for destination in distinct([for rule in local.ingress_rules : rule.destination]) : destination => [
      for rule in local.ingress_rules : rule if rule.destination == destination
    ]
  }
}

output "rules_count_by_protocol" {
  value = {
    for protocol in local.protocol_set : protocol => length([
      for rule in local.ingress_rules : rule if rule.protocol == protocol
    ])
  }
}

output "source_types" {
  value = {
    for key, rule in local.rules_by_key : key => rule.source == "-" ? "cidr" : "security_group"
  }
}

output "created_rule_ids" {
  value = {
    for key, rule in aws_vpc_security_group_ingress_rule.catalogue : key => rule.id
  }
}

output "unique_protocols" {
  value = local.protocol_set
}
