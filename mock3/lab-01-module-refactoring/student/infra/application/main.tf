data "terraform_remote_state" "shared" {
  backend = "local"

  config = {
    path = "../shared/terraform.tfstate"
  }
}

module "compute" {
  source = "../../modules/compute"

  providers = {
    aws.workload = aws.workload
  }

  account_id            = data.terraform_remote_state.shared.outputs.observer_account_id
  ami                   = var.ami
  instance_profile_name = data.terraform_remote_state.shared.outputs.instance_profile_name
  name_prefix           = "lab01-${var.environment}"
  subnet_ids            = data.terraform_remote_state.shared.outputs.subnet_ids
  security_group_ids    = data.terraform_remote_state.shared.outputs.security_group_ids
  workloads             = var.workloads
  common_tags           = var.common_tags
}
