output "normalized_rules" {
  value = local.normalized_rules
}

output "ingress_rule_keys" {
  value = sort(keys(local.rules_by_key))
}

output "rules_by_destination" {
  value = {
    for destination in distinct([for rule in local.ingress_rules : rule.destination]) :
    destination => [
      for rule in local.ingress_rules : rule
      if rule.destination == destination
    ]
  }
}

output "rules_count_by_protocol" {
  value = {
    for protocol in distinct([for rule in local.ingress_rules : rule.protocol]) :
    protocol => length([for rule in local.ingress_rules : rule if rule.protocol == protocol])
  }
}

output "source_types" {
  value = toset([
    for rule in local.ingress_rules : rule.source == "-" ? "cidr" : "security_group"
  ])
}

output "created_rule_ids" {
  value = { for key, rule in aws_vpc_security_group_ingress_rule.managed : key => rule.id }
}
