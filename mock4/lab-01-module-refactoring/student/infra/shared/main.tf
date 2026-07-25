locals {
  raw_csv_nodes  = csvdecode(file("${path.module}/../../data/nodes.csv"))
  raw_json_nodes = jsondecode(file("${path.module}/../../data/nodes.json"))
  raw_yaml_nodes = yamldecode(file("${path.module}/../../data/nodes.yaml"))

  csv_nodes = [for row in local.raw_csv_nodes : {
    key           = trimspace(row.key), subnet_key = trimspace(row.subnet_key),
    instance_type = trimspace(row.instance_type), enabled = lower(trimspace(row.enabled)) == "true",
    priority      = tonumber(row.priority), description = trimspace(row.description) == "" ? null : trimspace(row.description),
    team          = trimspace(row.team) == "" ? null : trimspace(row.team), tags = { Source = "csv" }
  }]
  json_nodes = [for row in local.raw_json_nodes : {
    key           = trimspace(tostring(row.key)), subnet_key = trimspace(tostring(row.subnet_key)),
    instance_type = trimspace(tostring(row.instance_type)), enabled = tobool(row.enabled),
    priority      = tonumber(row.priority), description = try(row.description, null) == "" ? null : try(row.description, null), team = try(row.team, null),
    tags          = tomap(try(row.tags, {}))
  }]
  yaml_nodes = [for row in local.raw_yaml_nodes : {
    key           = trimspace(tostring(row.key)), subnet_key = trimspace(tostring(row.subnet_key)),
    instance_type = trimspace(tostring(row.instance_type)), enabled = tobool(row.enabled),
    priority      = tonumber(row.priority), description = try(row.description, null) == "" ? null : try(row.description, null), team = try(row.team, null),
    tags          = tomap(lookup(row, "tags", {}))
  }]
  normalized_node_map = merge(
    { for node in local.csv_nodes : node.key => node },
    { for node in local.json_nodes : node.key => node },
    { for node in local.yaml_nodes : node.key => node },
  )

  enabled_node_map = {
    for key, node in local.normalized_node_map : key => node
    if node.enabled
  }
  subnet_map = { for subnet in var.subnet_specs : subnet.key => subnet }
  security_group_specs = {
    gateway  = { description = "North-south entry" }
    services = { description = "Internal services" }
    ops      = { description = "Operations access" }
  }
  cidr_rules = {
    gateway_https = { destination = "gateway", cidr = "0.0.0.0/0", from_port = 443, to_port = 443, protocol = "tcp", description = "Public TLS" }
    ops_ssh       = { destination = "ops", cidr = "10.48.0.0/16", from_port = 22, to_port = 22, protocol = "tcp", description = "Administrative shell" }
    services_dns  = { destination = "services", cidr = "10.48.0.0/16", from_port = 53, to_port = 53, protocol = "udp", description = "Internal DNS" }
  }
  peer_rules = {
    services_from_gateway = { destination = "services", source = "gateway", from_port = 8080, to_port = 8081, protocol = "tcp", description = "Gateway to services" }
    ops_from_services     = { destination = "ops", source = "services", from_port = 9100, to_port = 9100, protocol = "tcp", description = "Metrics scraping" }
  }
}

resource "random_pet" "label" {
  length    = 2
  separator = "-"
}

module "network" {
  source = "../../modules/network"

  name_prefix = random_pet.label.id
  subnets     = local.subnet_map
}

module "security" {
  source = "../../modules/security"

  name_prefix = random_pet.label.id
  vpc_id      = module.network.vpc_id
  groups      = local.security_group_specs
  cidr_rules  = local.cidr_rules
  peer_rules  = local.peer_rules
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "${random_pet.label.id}-artifact-vault"
}

resource "aws_s3_object" "manifest" {
  bucket       = aws_s3_bucket.artifacts.id
  key          = "manifests/runtime.txt"
  content      = "namespace=${random_pet.label.id}\nworkloads=${join(",", sort(keys(local.enabled_node_map)))}\n"
  content_type = "text/plain"
}

resource "aws_s3_bucket" "state_store" {
  bucket = "tfpro-lab01-state-nimbus"
}
