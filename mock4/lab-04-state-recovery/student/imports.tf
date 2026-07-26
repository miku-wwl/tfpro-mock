import {
  to = aws_s3_bucket.logs
  id = local.baseline.buckets.logs
}

import {
  to = aws_security_group.application
  id = local.baseline.security_group.id
}

import {
  for_each = local.rule_import_targets
  to       = aws_vpc_security_group_ingress_rule.inbound[each.key]
  id       = each.value
}
