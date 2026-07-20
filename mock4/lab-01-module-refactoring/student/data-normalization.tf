locals {
  raw_csv_nodes  = csvdecode(file("${path.module}/data/nodes.csv"))
  raw_json_nodes = jsondecode(file("${path.module}/data/nodes.json"))
  raw_yaml_nodes = yamldecode(file("${path.module}/data/nodes.yaml"))

  csv_nodes = [
    for row in local.raw_csv_nodes : {
      key           = trimspace(row.key)
      subnet_key    = trimspace(row.subnet_key)
      instance_type = trimspace(row.instance_type)
      enabled       = lower(trimspace(row.enabled)) == "true"
      priority      = tonumber(row.priority)
      description   = trimspace(row.description) == "" ? null : trimspace(row.description)
      team          = trimspace(row.team) == "" ? null : trimspace(row.team)
      tags          = tomap({ Source = "csv" })
    }
  ]

  json_nodes = [
    for row in local.raw_json_nodes : {
      key           = trimspace(tostring(row.key))
      subnet_key    = trimspace(tostring(row.subnet_key))
      instance_type = trimspace(tostring(row.instance_type))
      enabled       = tobool(row.enabled)
      priority      = tonumber(row.priority)
      description   = try(row.description, null)
      team          = try(row.team, null)
      tags          = tomap(try(row.tags, {}))
    }
  ]

  yaml_nodes = [
    for row in local.raw_yaml_nodes : {
      key           = trimspace(tostring(row.key))
      subnet_key    = trimspace(tostring(row.subnet_key))
      instance_type = trimspace(tostring(row.instance_type))
      enabled       = tobool(row.enabled)
      priority      = tonumber(row.priority)
      description   = try(row.description, null) == "" ? null : try(row.description, null)
      team          = try(row.team, null)
      tags          = tomap(lookup(row, "tags", {}))
    }
  ]

  all_nodes = flatten([
    local.csv_nodes,
    local.json_nodes,
    local.yaml_nodes,
  ])

  csv_node_map  = { for node in local.csv_nodes : node.key => node }
  json_node_map = { for node in local.json_nodes : node.key => node }
  yaml_node_map = { for node in local.yaml_nodes : node.key => node }

  # Explicit source precedence resolves duplicate semantic keys without row indexes.
  normalized_node_map = merge(
    local.csv_node_map,
    local.json_node_map,
    local.yaml_node_map,
  )

  enabled_node_map = {
    for key, node in local.normalized_node_map : key => node
    if node.enabled
  }

  unique_teams = toset(distinct(compact([
    for node in values(local.normalized_node_map) : node.team
  ])))
}
