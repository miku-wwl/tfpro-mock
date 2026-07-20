locals {
  name_seed = "${var.project_code}-${random_pet.cohort.id}"

  segment_specs = {
    for segment in var.segment_blueprints : segment.key => segment
  }
}

resource "random_pet" "cohort" {
  length    = 2
  separator = "-"

  lifecycle {
    prevent_destroy = true
  }
}

module "shared" {
  source = "../../modules/network"

  name_seed     = local.name_seed
  vpc_cidr      = var.vpc_cidr
  segment_specs = local.segment_specs
}

module "security" {
  source = "../../modules/security"

  name_seed = local.name_seed
  vpc_id    = module.shared.vpc_id
  groups    = var.security_groups
  rules     = var.ingress_rules
}

resource "aws_s3_bucket" "artifact_store" {
  bucket = "${local.name_seed}-artifacts"

  tags = {
    Name = "${local.name_seed}-artifacts"
    Lab  = "tfpro-state-addresses"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_object" "seed_manifest" {
  bucket       = aws_s3_bucket.artifact_store.id
  key          = "bootstrap/manifest.json"
  content_type = "application/json"
  content = jsonencode({
    project  = var.project_code
    cohort   = random_pet.cohort.id
    segments = [for segment in var.segment_blueprints : segment.key]
  })

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "state_store" {
  bucket = "${local.name_seed}-state"

  tags = {
    Name = "${local.name_seed}-state"
    Lab  = "tfpro-state-addresses"
  }

  lifecycle {
    prevent_destroy = true
  }
}
