locals {
  baseline = jsondecode(file("${path.module}/baseline/baseline.json"))

  csv_rows = [
    for row in csvdecode(file("${path.module}/data/recovery.csv")) :
    merge(row, { source_format = "csv" })
  ]

  json_rows = [
    for row in jsondecode(file("${path.module}/data/recovery.json")).items :
    merge(row, { source_format = "json" })
  ]

  yaml_rows = [
    for row in yamldecode(file("${path.module}/data/recovery.yaml")).items :
    merge(row, { source_format = "yaml" })
  ]

  raw_inventory = flatten([
    local.csv_rows,
    local.json_rows,
    local.yaml_rows,
  ])

  normalized_inventory = [
    for item in local.raw_inventory : {
      kind          = tostring(item.kind)
      address_key   = tostring(item.address_key)
      remote_suffix = try(item.remote_suffix, null) == null || try(item.remote_suffix, "") == "" ? null : tostring(item.remote_suffix)
      enabled       = item.enabled == null ? false : try(tobool(item.enabled), false)
      priority      = item.priority == null || try(item.priority, "") == "" ? 0 : tonumber(item.priority)
      keep_remote   = item.keep_remote == null || try(item.keep_remote, "") == "" ? false : try(tobool(item.keep_remote), false)
      description   = tostring(item.description)
      source_format = tostring(item.source_format)
    }
  ]

  enabled_inventory = [
    for item in local.normalized_inventory : item if item.enabled
  ]

  distinct_enabled_inventory = distinct(local.enabled_inventory)

  inventory_by_identity = {
    for identity in distinct([
      for item in local.distinct_enabled_inventory : "${item.kind}:${item.address_key}"
      ]) : identity => [
      for item in local.distinct_enabled_inventory : item
      if "${item.kind}:${item.address_key}" == identity
    ]
  }

  ranked_inventory = {
    for identity, items in local.inventory_by_identity : identity => {
      for item in items : format(
        "%010d|%s|%s|%s",
        999999 - item.priority,
        item.source_format,
        item.description,
        sha1(jsonencode(item))
      ) => item
    }
  }

  # TRAP: a direct { for item in ... : "${item.kind}:${item.address_key}" => item }
  # fails because logical duplicates exist.
  #
  # TRAP: item.enabled ? { (item.address_key) = item } : []
  # fails because the conditional branches have object and tuple types.
  canonical_inventory = {
    for identity, ranked in local.ranked_inventory : identity => ranked[sort(keys(ranked))[0]]
  }

  # Build stable maps from canonical_inventory. Never key by row index.
  # The false filters preserve useful static element types while keeping the
  # later task-specific maps out of this normalization task.
  iam_members = {
    for identity, item in local.canonical_inventory : item.address_key => {
      name        = local.baseline.iam_users[item.address_key]
      description = item.description
    } if item.kind == "iam_user"
  }

  active_rule_specs = {
    for identity, item in local.canonical_inventory : item.address_key => merge(
      {
        "ops-tcp-8443" = {
          from_port   = 8443
          to_port     = 8443
          ip_protocol = "tcp"
          cidr_ipv4   = "10.64.10.0/24"
        }
        "audit-tcp-9443" = {
          from_port   = 9443
          to_port     = 9443
          ip_protocol = "tcp"
          cidr_ipv4   = "10.64.20.0/24"
        }
      }[item.address_key],
      { description = item.description }
    ) if item.kind == "security_group_rule"
  }

  rule_import_targets = {
    for identity, item in local.canonical_inventory : item.address_key =>
    local.baseline.security_group.rule_ids[item.address_key]
    if item.kind == "security_group_rule"
  }

  security_rule_specs = local.active_rule_specs
}
