resource "aws_vpc_security_group_ingress_rule" "policy" {
  for_each = local.ingress_rule_map

  security_group_id = local.security_group_ids[each.value.destination]
  ip_protocol       = each.value.protocol

  # TODO: Resolve CIDR and security-group sources dynamically and exclusively.
  cidr_ipv4                    = each.value.source == "-" ? "10.67.12.0/24" : local.subnet_cidrs["dmz_net"]
  referenced_security_group_id = each.value.source == "-" ? null : "sg-0123456789abcdef0"

  # TODO: Handle null ports and protocol -1 according to the provider schema.
  from_port = each.value.from_port == "" ? 0 : each.value.from_port
  to_port   = each.value.to_port == "" ? 0 : each.value.to_port

  description = each.value.description
}
