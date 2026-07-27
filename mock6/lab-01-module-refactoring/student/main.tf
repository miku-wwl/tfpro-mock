module "network" {
  source = "./modules/network"

  name_prefix   = "northstar-${random_pet.release_marker.id}"
  network_spec  = var.network_layout
  resource_tags = local.common_tags
}

module "security" {
  source = "./modules/security"

  name_prefix       = "northstar-${random_pet.release_marker.id}"
  vpc_id            = module.network.vpc_id
  group_definitions = local.security_profiles
  operator_cidrs    = var.operator_cidrs
  resource_tags     = local.common_tags
}

module "identity" {
  source = "./modules/identity"

  naming_context = {
    prefix = "northstar"
    stage  = random_pet.release_marker.id
  }
  resource_tags = local.common_tags
}

module "compute" {
  source = "./modules/compute"

  name_prefix           = "northstar-${random_pet.release_marker.id}"
  ami_id                = "ami-c615e0c9"
  subnet_ids            = module.network.subnet_ids
  security_group_ids    = module.security.security_group_ids
  instance_profile_name = module.identity.instance_profile_name
  nodes                 = var.node_catalog
  resource_tags         = local.common_tags
}
