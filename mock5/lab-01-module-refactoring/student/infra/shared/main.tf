resource "random_pet" "naming" {
  length    = 2
  separator = "-"
}

module "network" {
  source              = "../../modules/network"
  name_stem           = var.name_stem
  vpc_cidr            = var.vpc_cidr
  segment_definitions = var.segment_definitions
}

module "security" {
  source         = "../../modules/security"
  name_stem      = var.name_stem
  vpc_id         = module.network.vpc_id
  security_tiers = var.security_tiers
  ingress_rules  = var.ingress_rules
}

resource "aws_s3_bucket" "artifacts" {
  bucket = substr(lower("${var.name_stem}-${random_pet.naming.id}-artifacts"), 0, 63)
}

resource "aws_s3_bucket" "state_store" {
  bucket = "tfpro-lab01-state-archive"
}

resource "aws_s3_object" "manifest" {
  bucket       = aws_s3_bucket.artifacts.id
  key          = var.artifact_object_key
  content_type = "application/json"
  content      = jsonencode({ platform_id = module.network.vpc_id, name_token = random_pet.naming.id })
}
