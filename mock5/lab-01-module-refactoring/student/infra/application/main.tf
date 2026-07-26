module "identity" {
  source        = "../../modules/identity"
  name_stem     = var.name_stem
  shared_naming = { token = var.shared_name_token }
}

module "compute" {
  source                = "../../modules/compute"
  name_stem             = var.name_stem
  shared_name_token     = var.shared_name_token
  base_ami              = var.base_ami
  subnet_ids            = var.subnet_ids
  security_group_ids    = var.security_group_ids
  instance_profile_name = module.identity.instance_profile_name
  workload_roles        = var.workload_roles
}
