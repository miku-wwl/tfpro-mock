data "terraform_remote_state" "shared" {
  backend = "s3"

  config = {
    bucket                      = var.state_bucket_name
    key                         = "tfpro-sim/lab-01/shared.tfstate"
    region                      = var.aws_region
    endpoints                   = { s3 = var.localstack_endpoint }
    use_path_style              = true
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    access_key                  = "test"
    secret_key                  = "test"
  }
}

locals {
  shared = data.terraform_remote_state.shared.outputs.shared_contract
}

module "application" {
  source = "../../modules/identity"

  name_seed = "${var.project_code}-${local.shared.naming_seed}"
}

module "compute" {
  source = "../../modules/compute"

  name_seed = "${var.project_code}-${local.shared.naming_seed}"
  ami_id    = var.localstack_ami_id
  nodes     = var.instances

  subnet_ids_by_key = {
    "edge-a" = local.shared.subnet_ids_by_key["edge-a"]
    "edge-b" = local.shared.subnet_ids_by_key["edge-b"]
  }

  security_group_ids    = local.shared.security_group_ids
  instance_profile_name = module.application.instance_profile_name

}
