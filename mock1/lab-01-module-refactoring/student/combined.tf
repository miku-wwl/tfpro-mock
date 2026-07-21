resource "random_pet" "suffix" {
  length    = 2
  separator = "-"
}


module "network" {
  source = "./modules/network"

  network = {
    cidr_block = "10.42.0.0/16"
    tags = {
      Name        = "${local.naming.project}-vpc"
      Environment = local.naming.environment
      Owner       = local.naming.owner
    }
  }

  subnets = { for subnet in local.subnet_specs : subnet.key => {
    key               = subnet.key
    cidr_block        = subnet.cidr_block
    availability_zone = subnet.availability_zone

    tags = {
      Name        = "${local.naming.project}-${subnet.name}"
      Environment = local.naming.environment
    }
    }
  }
}

module "security" {
  source = "./modules/security"
  vpc_id = module.network.vpc_id
  security_groups = {
    for k, v in local.security_groups : k => {
      name        = "${local.naming.project}-${k}-sg"
      description = v.description
      tags = {
        Name        = "${local.naming.project}-${k}-sg"
        Environment = local.naming.environment
      }
    }
  }
  ingress_rules = local.ingress_rules

}

module "identity" {
  source = "./modules/identity"

  naming = {
    label  = local.naming.project
    suffix = random_pet.suffix.id
  }
  tags = {
    Environment = local.naming.environment
    Owner       = local.naming.owner
  }
}

module "compute" {
  source = "./modules/compute"

  ami_id = var.ami_id
  instances = {
    for k, v in local.instances : k => {
      subnet_key          = v.subnet_key
      subnet_index        = v.subnet_index
      security_group_keys = v.security_group_keys
      instance_type       = v.instance_type
      tags = {
        Name        = "${local.naming.project}-${random_pet.suffix.id}-${k}"
        Environment = local.naming.environment
        Role        = k
      }
    }
  }

  subnet_ids            = module.network.subnet_ids
  security_group_ids    = module.security.security_group_ids
  instance_profile_name = module.identity.instance_profile_name
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "${local.naming.project}-${random_pet.suffix.id}-artifacts"

  tags = {
    Environment = local.naming.environment
    Owner       = local.naming.owner
  }
}

resource "aws_s3_object" "manifest" {
  bucket       = aws_s3_bucket.artifacts.id
  key          = "manifests/platform.json"
  content_type = "application/json"
  content = jsonencode({
    environment = local.naming.environment
    instances   = sort(keys(local.instances))
    suffix      = random_pet.suffix.id
  })
}

resource "aws_s3_bucket" "state_store" {
  bucket = "driftwood-lab01-state-vault"

  tags = {
    Purpose = "terraform-state"
    Lab     = "lab-01"
  }
}
