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

  # TODO: Normalize mixed string/number/bool/null/empty-string values.
  # Preserve semantic null for remote_suffix instead of coercing it to "".
  normalized_inventory = []

  # TRAP: a direct { for item in ... : "${item.kind}:${item.address_key}" => item }
  # fails because logical duplicates exist.
  #
  # TRAP: item.enabled ? { (item.address_key) = item } : []
  # fails because the conditional branches have object and tuple types.
  canonical_inventory = {}

  # TODO: Build stable maps from canonical_inventory. Never key by row index.
  # The false filters preserve useful static element types while keeping the
  # starter maps empty and validation-friendly.
  iam_members = {
    for key, value in {
      placeholder = {
        name        = ""
        description = ""
      }
    } : key => value if false
  }

  active_rule_specs = {
    for key, value in {
      placeholder = {
        description = ""
        from_port   = 0
        to_port     = 0
        ip_protocol = "tcp"
        cidr_ipv4   = "127.0.0.1/32"
      }
    } : key => value if false
  }

  rule_import_targets = {
    for key, value in { placeholder = "sgr-placeholder" } :
    key => value if false
  }

  security_rule_specs = {
    "ops-tcp-8443" = {
      description = "Operations access"
      from_port   = 8443
      to_port     = 8443
      ip_protocol = "tcp"
      cidr_ipv4   = "10.44.0.0/16"
    }
    "audit-tcp-9443" = {
      description = "Audit access"
      from_port   = 9443
      to_port     = 9443
      ip_protocol = "tcp"
      cidr_ipv4   = "10.55.0.0/16"
    }
  }
}
