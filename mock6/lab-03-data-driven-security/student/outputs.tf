output "normalized_rules" {
  value = local.normalized_rules
}

output "ingress_rule_keys" {
  value = keys(local.rule_instances)
}

output "rules_by_destination" {
  value = {
    for row in local.normalized_rules :
    row.destination => row...
    if row.direction == "ingress" && row.enabled
  }
}

output "rules_count_by_protocol" {
  value = {
    for protocol in distinct([for row in local.rule_instances : row.protocol]) :
    protocol => length([for row in local.rule_instances : row if row.protocol == protocol])
  }
}

output "source_types" {
  value = toset([
    for row in local.rule_instances :
    row.source == "-" ? "subnet" : "security-group"
  ])
}

output "created_rule_ids" {
  value = {
    for key, rule in aws_vpc_security_group_ingress_rule.policy : key => rule.id
  }
}
