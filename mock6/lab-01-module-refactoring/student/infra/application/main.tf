data "terraform_remote_state" "shared" {
  backend = "s3"
  config  = { bucket = "northstar-amusing-piglet-tfstate", key = "tfpro-sim/final-06/lab-01/shared.tfstate", region = "us-east-1" }
}
locals { common_tags = { ManagedBy = "Terraform", Owner = "platform-foundation", CostCentre = "cc-4821", Service = "northstar-relay", Stage = "simulation", Lab = "final-06-lab-01" } }
module "identity" {
  source         = "../../modules/identity"
  naming_context = { prefix = "northstar", stage = data.terraform_remote_state.shared.outputs.shared_name }
  resource_tags  = local.common_tags
}
module "compute" {
  source                = "../../modules/compute"
  name_prefix           = "northstar-${data.terraform_remote_state.shared.outputs.shared_name}"
  ami_id                = "ami-c615e0c9"
  subnet_ids            = data.terraform_remote_state.shared.outputs.subnet_ids
  security_group_ids    = data.terraform_remote_state.shared.outputs.security_group_ids
  instance_profile_name = module.identity.instance_profile_name
  nodes                 = var.node_catalog
  resource_tags         = local.common_tags
}
