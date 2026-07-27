resource "random_pet" "release_marker" {
  length    = 2
  separator = "-"
}
locals {
  common_tags = {
    ManagedBy  = "Terraform"
    Owner      = var.business_metadata.owner
    CostCentre = var.business_metadata.cost_centre
    Service    = var.business_metadata.service
    Stage      = var.business_metadata.stage
    Lab        = "final-06-lab-01"
  }
  security_profiles = {
    edge       = { description = "Public TLS entry boundary" }
    service    = { description = "Internal message-processing boundary" }
    operations = { description = "Restricted operator boundary" }
  }
}
module "network" {
  source        = "../../modules/network"
  name_prefix   = "northstar-${random_pet.release_marker.id}"
  network_spec  = var.network_layout
  resource_tags = local.common_tags
}
module "security" {
  source            = "../../modules/security"
  name_prefix       = "northstar-${random_pet.release_marker.id}"
  vpc_id            = module.network.vpc_id
  group_definitions = local.security_profiles
  operator_cidrs    = var.operator_cidrs
  resource_tags     = local.common_tags
}
resource "aws_s3_bucket" "artifact_store" {
  bucket        = "northstar-${random_pet.release_marker.id}-artifacts"
  force_destroy = true
  tags          = { Name = "northstar-${random_pet.release_marker.id}-artifacts" }
}
resource "aws_s3_object" "relay_manifest" {
  bucket       = aws_s3_bucket.artifact_store.id
  key          = "manifests/relay.json"
  content_type = "application/json"
  content      = jsonencode({ service = var.business_metadata.service, stage = var.business_metadata.stage, release = random_pet.release_marker.id })
}
resource "aws_s3_bucket" "state_archive" {
  bucket        = "northstar-${random_pet.release_marker.id}-tfstate"
  force_destroy = true
  tags          = { Name = "northstar-${random_pet.release_marker.id}-tfstate", Purpose = "Terraform state" }
}
