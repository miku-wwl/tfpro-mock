resource "aws_vpc_security_group_ingress_rule" "this" {
  provider = aws.rules
  for_each = var.rules

  security_group_id = lookup(
    var.security_group_ids,
    each.value.destination,
    "sg-0123456789abcdef0"
  )

  cidr_ipv4 = each.value.source == "-" ? lookup(
    var.subnet_cidrs,
    each.value.source_selector,
    "10.73.0.0/16"
  ) : "10.73.0.0/16"

  referenced_security_group_id = lookup(
    var.security_group_ids,
    each.value.source,
    "sg-0123456789abcdef0"
  )

  ip_protocol = each.value.protocol
  from_port   = each.value.from_port == "" ? "" : each.value.from_port
  to_port     = each.value.to_port == "" ? "" : each.value.to_port
  description = "account=000000000000 | ${each.value.description}"
}
