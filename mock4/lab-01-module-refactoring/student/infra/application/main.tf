data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    bucket                      = "tfpro-lab01-state-nimbus"
    key                         = "REPLACE_WITH_REQUIRED_SHARED_KEY"
    region                      = var.aws_region
    access_key                  = "test"
    secret_key                  = "test"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    use_path_style              = true
    endpoints = {
      s3 = var.localstack_endpoint
    }
  }
}

module "identity" {
  source = "../../modules/identity"

  # Deliberate defect: this input is not declared by the child module.
  shared_label = data.terraform_remote_state.shared.outputs.shared_contract.name_prefix
}

module "compute" {
  source = "../../modules/compute"

  name_prefix          = data.terraform_remote_state.shared.outputs.shared_contract.name_prefix
  subnet_ids           = data.terraform_remote_state.shared.outputs.shared_contract.subnet_ids
  security_group_ids   = data.terraform_remote_state.shared.outputs.shared_contract.sg_ids
  instance_profile     = module.identity.instance_profile_name
  instances            = data.terraform_remote_state.shared.outputs.normalized_node_map
}
