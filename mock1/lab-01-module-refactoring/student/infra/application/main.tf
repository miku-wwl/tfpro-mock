data "terraform_remote_state" "shared" {
  backend = "s3"

  config = {
    bucket = "driftwood-lab01-state-vault"
    key    = "tfpro-sim/lab-01/shared.tfstate"
    region = "us-east-1"

    access_key = "test"
    secret_key = "test"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true

    use_path_style = true

    endpoints = {
      s3 = "http://localhost:4566"
    }
  }
}

module "identity" {
  source = "../../modules/identity"

  naming = {
    label  = data.terraform_remote_state.shared.outputs.naming.project
    suffix = data.terraform_remote_state.shared.outputs.naming.suffix
  }

  tags = {
    Environment = data.terraform_remote_state.shared.outputs.naming.environment
    Owner       = data.terraform_remote_state.shared.outputs.naming.owner
  }
}

module "compute" {
  source = "../../modules/compute"

  ami_id = var.ami_id

  subnet_ids = data.terraform_remote_state.shared.outputs.subnet_ids

  security_group_ids = data.terraform_remote_state.shared.outputs.security_group_ids

  instance_profile_name = module.identity.instance_profile_name

  instances = {
    gateway = {
      subnet_key          = "north"
      subnet_index        = 0
      security_group_keys = toset(["edge", "ops"])
      instance_type       = "t3.micro"

      tags = {
        Name        = "driftwood-better-gull-gateway"
        Environment = "assessment"
        Role        = "gateway"
      }
    }

    worker = {
      subnet_key          = "south"
      subnet_index        = 1
      security_group_keys = toset(["service"])
      instance_type       = "t3.micro"

      tags = {
        Name        = "driftwood-better-gull-worker"
        Environment = "assessment"
        Role        = "worker"
      }
    }
  }
}