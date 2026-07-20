locals {
  policy_paths = {
    csv  = "${path.module}/data/rules.csv"
    json = "${path.module}/data/rules.json"
    yaml = "${path.module}/data/rules.yaml"
  }

  raw_rules = var.rules_format == "csv" ? csvdecode(file(local.policy_paths.csv)) : (
    var.rules_format == "json" ? jsondecode(file(local.policy_paths.json)) : yamldecode(file(local.policy_paths.yaml))
  )

  normalized_rules = [
    for row in local.raw_rules : {
      direction       = lower(trimspace(tostring(row.direction)))
      source          = trimspace(tostring(row.source))
      destination     = trimspace(tostring(lookup(row, "destnation", "")))
      from_port       = row.from_port
      to_port         = row.to_port
      protocol        = lower(trimspace(tostring(row.protocol)))
      source_selector = trimspace(tostring(row.source_selector))
      description     = trimspace(tostring(row.description))
      enabled         = row.enabled
    }
  ]

  destination_port_map = {
    for row in local.normalized_rules :
    "${row.destination}:${row.from_port}" => row
  }

  source_resolution_preview = [
    for row in local.normalized_rules :
    row.source == "-" ? data.aws_subnet.network[row.source_selector].cidr_block : [data.aws_security_group.zone[row.source].id]
  ]

  rule_instances = {
    for index, row in local.normalized_rules :
    "${index}-${row.destination}-${row.from_port}" => row
  }

  security_group_ids = {
    for role, group in data.aws_security_group.zone : role => group.id
  }
}

resource "aws_vpc_security_group_ingress_rule" "policy" {
  for_each = local.rule_instances

  security_group_id            = local.security_group_ids[each.value.destination]
  cidr_ipv4                    = each.value.source == "-" ? "10.77.10.0/24" : each.value.source
  referenced_security_group_id = try(local.security_group_ids[each.value.source], "sg-0123456789abcdef0")

  from_port   = each.value.protocol == "-1" ? "" : each.value.from_port
  to_port     = each.value.protocol == "-1" ? "" : each.value.to_port
  ip_protocol = each.value.protocol
  description = each.value.description
}
