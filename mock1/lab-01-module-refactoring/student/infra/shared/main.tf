resource "random_pet" "suffix" {
  length    = 2
  separator = "-"
}

module "network" {
  source = "../../modules/network"

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
  source = "../../modules/security"
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
    instances   = ["gateway", "worker"]
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
