locals {
  csv_raw  = csvdecode(file("${path.module}/data/profile-catalog.csv"))
  json_raw = jsondecode(file("${path.module}/data/profile-overrides.json"))
  yaml_raw = yamldecode(file("${path.module}/data/profile-policy.yaml"))

  # BUG: CSV branches return list and string, so the object shape is unstable.
  csv_profiles = [
    for row in local.csv_raw : {
      map_key        = trimspace(row.map_key)
      profile_name   = trimspace(row.profile_name)
      role_name      = trimspace(row.role_name)
      role_arn       = trimspace(row.role_arn)
      source_profile = trimspace(row.source_profile)
      region         = trimspace(row.region)
      output         = trimspace(row.output)
      enabled        = row.enabled
      session_ttl    = row.session_ttl
      module_targets = trimspace(row.module_targets) == "" ? [] : row.module_targets
      priority       = 10
    }
  ]

  # BUG: duplicate logical keys from CSV and JSON collide here.
  profile_matrix = {
    for item in concat(local.csv_profiles, local.json_raw.records, local.yaml_raw.records) :
    item.map_key => item
  }

  # BUG: this assumes alias name, map key, and profile name are identical.
  module_bindings = {
    compute  = "compute-operator"
    identity = "identity-operator"
    storage  = "compute-operator"
    audit    = "readonly-auditor"
  }
}
