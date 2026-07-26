module "identity" {
  source        = "../../modules/identity"
  name_stem     = var.name_stem
  shared_naming = { token = data.terraform_remote_state.shared.outputs.shared_name_token }
}

module "compute" {
  source                = "../../modules/compute"
  name_stem             = var.name_stem
  shared_name_token     = data.terraform_remote_state.shared.outputs.shared_name_token
  base_ami              = var.base_ami
  subnet_ids            = data.terraform_remote_state.shared.outputs.subnet_ids_by_zone
  security_group_ids    = data.terraform_remote_state.shared.outputs.security_group_ids_by_tier
  instance_profile_name = module.identity.instance_profile_name
  workload_roles        = var.workload_roles
}
