locals {
  csv_raw  = csvdecode(file("${path.module}/data/profile-catalog.csv"))
  json_raw = jsondecode(file("${path.module}/data/profile-overrides.json"))
  yaml_raw = yamldecode(file("${path.module}/data/profile-policy.yaml"))

  csv_profiles = {
    for row in local.csv_raw : row.map_key => {
      map_key        = trimspace(row.map_key)
      profile_name   = trimspace(row.profile_name)
      role_name      = trimspace(row.role_name)
      role_arn       = trimspace(row.role_arn)
      source_profile = trimspace(row.source_profile)
      region         = trimspace(row.region)
      output         = trimspace(row.output) == "" ? null : trimspace(row.output)
      enabled        = tobool(row.enabled)
      session_ttl    = tonumber(row.session_ttl)
      module_targets = trimspace(row.module_targets) == "" ? toset([]) : toset(split("|", trimspace(row.module_targets)))
      note           = trimspace(row.note) == "" ? null : trimspace(row.note)
      priority       = 10
    }
  }

  json_keys = distinct([for row in local.json_raw.records : tostring(row.map_key)])
  json_profiles = {
    for key in local.json_keys : key => {
      map_key        = key
      profile_name   = try(local.csv_profiles[key].profile_name, null)
      role_name      = try(local.csv_profiles[key].role_name, null)
      role_arn       = try(local.csv_profiles[key].role_arn, null)
      source_profile = try(local.csv_profiles[key].source_profile, null)
      region         = try(local.csv_profiles[key].region, null)
      output         = try([for row in local.json_raw.records : row.output if tostring(row.map_key) == key && try(row.output, null) != null][length([for row in local.json_raw.records : row.output if tostring(row.map_key) == key && try(row.output, null) != null]) - 1], null)
      enabled        = try([for row in local.json_raw.records : tobool(row.enabled) if tostring(row.map_key) == key][length([for row in local.json_raw.records : row.enabled if tostring(row.map_key) == key]) - 1], null)
      session_ttl    = try([for row in local.json_raw.records : tonumber(row.session_ttl) if tostring(row.map_key) == key && try(row.session_ttl, null) != null][length([for row in local.json_raw.records : row.session_ttl if tostring(row.map_key) == key && try(row.session_ttl, null) != null]) - 1], null)
      module_targets = toset(flatten([for row in local.json_raw.records : [for target in try(row.module_targets, []) : tostring(target)] if tostring(row.map_key) == key]))
      note           = try([for row in local.json_raw.records : row.note if tostring(row.map_key) == key && try(row.note, null) != null][length([for row in local.json_raw.records : row.note if tostring(row.map_key) == key && try(row.note, null) != null]) - 1], null)
      priority       = try(max([for row in local.json_raw.records : tonumber(row.priority) if tostring(row.map_key) == key]), null)
    }
  }

  yaml_keys = distinct([for row in local.yaml_raw.records : tostring(row.map_key)])
  yaml_profiles = {
    for key in local.yaml_keys : key => {
      map_key        = key
      profile_name   = try(local.json_profiles[key].profile_name, try(local.csv_profiles[key].profile_name, null))
      role_name      = try(local.json_profiles[key].role_name, try(local.csv_profiles[key].role_name, null))
      role_arn       = try(local.json_profiles[key].role_arn, try(local.csv_profiles[key].role_arn, null))
      source_profile = try(local.json_profiles[key].source_profile, try(local.csv_profiles[key].source_profile, null))
      region         = try([for row in local.yaml_raw.records : row.region if tostring(row.map_key) == key && try(row.region, null) != null][0], local.yaml_raw.defaults.region)
      output         = try([for row in local.yaml_raw.records : row.output if tostring(row.map_key) == key && try(row.output, null) != null][0], local.yaml_raw.defaults.output)
      enabled        = try([for row in local.yaml_raw.records : tobool(row.enabled) if tostring(row.map_key) == key && try(row.enabled, null) != null][0], local.yaml_raw.defaults.enabled)
      session_ttl    = try([for row in local.yaml_raw.records : tonumber(row.session_ttl) if tostring(row.map_key) == key && try(row.session_ttl, null) != null][0], local.yaml_raw.defaults.session_ttl)
      module_targets = toset(flatten([for row in local.yaml_raw.records : [for target in try(row.module_targets, []) : tostring(target)] if tostring(row.map_key) == key]))
      note           = try([for row in local.yaml_raw.records : row.note if tostring(row.map_key) == key && try(row.note, null) != null][0], null)
      priority       = try([for row in local.yaml_raw.records : tonumber(row.priority) if tostring(row.map_key) == key && try(row.priority, null) != null][0], null)
    }
  }

  # 后来的格式覆盖前面的格式：CSV < JSON < YAML。
  profile_matrix = merge(local.csv_profiles, local.json_profiles, local.yaml_profiles)

  module_bindings = {
    compute  = local.profile_matrix.compute.profile_name
    identity = local.profile_matrix.identity.profile_name
    storage  = local.profile_matrix.compute.profile_name
    audit    = local.profile_matrix.audit.profile_name
  }
}
