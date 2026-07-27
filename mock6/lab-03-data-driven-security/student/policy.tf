locals {
  policy_paths = {
    csv  = "${path.module}/data/rules.csv"
    json = "${path.module}/data/rules.json"
    yaml = "${path.module}/data/rules.yaml"
  }

  decoded_rules = {
    csv  = csvdecode(file(local.policy_paths.csv))
    json = jsondecode(file(local.policy_paths.json))
    yaml = yamldecode(file(local.policy_paths.yaml))
  }

  raw_rules = local.decoded_rules[var.rules_format]

  normalized_rules = [
    for row in local.raw_rules : {
      direction       = lower(trimspace(tostring(row.direction)))
      source          = trimspace(tostring(row.source))
      destination     = trimspace(tostring(lookup(row, "destination", "")))
      from_port       = try(tonumber(row.from_port), null)
      to_port         = try(tonumber(row.to_port), null)
      protocol        = lower(trimspace(tostring(row.protocol)))
      source_selector = trimspace(tostring(row.source_selector))
      description     = trimspace(tostring(row.description))
      enabled         = try(tobool(row.enabled), lower(trimspace(tostring(row.enabled))) == "true")
    }
  ]

  destination_port_map = {
    for row in local.normalized_rules :
    "${row.source}|${row.destination}|${row.protocol}|${row.from_port == null ? "" : tostring(row.from_port)}|${row.to_port == null ? "" : tostring(row.to_port)}" => row
    if row.direction == "ingress" && lower(row.enabled) == "true"
  }

  source_resolution_preview = [
    for row in local.normalized_rules :
    row.source == "-" ? data.aws_subnet.network[row.source_selector].cidr_block : data.aws_security_group.zone[row.source].id
  ]

  rule_instances = {
    for key, row in local.destination_port_map :
    key => row
  }

  security_group_ids = {
    for role, group in data.aws_security_group.zone : role => group.id
  }
}

resource "aws_vpc_security_group_ingress_rule" "policy" {
  for_each = local.rule_instances

  security_group_id            = local.security_group_ids[each.value.destination]
  cidr_ipv4                    = each.value.source == "-" ? data.aws_subnet.network[each.value.source_selector].cidr_block : null
  referenced_security_group_id = each.value.source == "-" ? null : local.security_group_ids[each.value.source]

  from_port   = each.value.protocol == "-1" ? null : each.value.from_port
  to_port     = each.value.protocol == "-1" ? null : each.value.to_port
  ip_protocol = each.value.protocol
  description = each.value.description
}
