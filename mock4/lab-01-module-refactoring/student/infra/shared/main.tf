locals {
  raw_csv_nodes  = csvdecode(file("${path.module}/../../data/nodes.csv"))
  raw_json_nodes = jsondecode(file("${path.module}/../../data/nodes.json"))
  raw_yaml_nodes = yamldecode(file("${path.module}/../../data/nodes.yaml"))

  # Deliberate defect: duplicate keys from all sources collide here.
  all_nodes = flatten([local.raw_csv_nodes, local.raw_json_nodes, local.raw_yaml_nodes])
  node_map  = { for item in local.all_nodes : item.key => item }

  # Deliberate defect: set values do not have stable numeric indexes.
  team_set   = toset(["platform", "analytics", "security"])
  first_team = local.team_set[0]
}

resource "random_pet" "label" {
  length    = 2
  separator = "-"
}

module "network" {
  source = "../../modules/network"

  name_prefix = random_pet.label.id
  # Deliberate defect: the module contract and root value shape do not agree.
  subnets = var.subnet_specs[0]
}

module "security" {
  source = "../../modules/security"

  name_prefix = random_pet.label.id
  vpc_id      = module.network.vpc_id
}
