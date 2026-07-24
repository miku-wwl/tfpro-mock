resource "random_pet" "scope" {
  length = 2
}

locals {
  name_prefix = "${random_pet.scope.id}-${var.environment}"
}

module "network" {
  source             = "../../modules/network"
  providers          = { aws.network = aws.network }
  cidr               = var.address_space.cidr
  subnet_cidrs       = var.address_space.subnet_cidrs
  availability_zones = var.address_space.availability_zones
  name_prefix        = local.name_prefix
  common_tags        = var.common_tags
}

module "security" {
  source         = "../../modules/security"
  providers      = { aws.network = aws.network, aws.readonly = aws.readonly }
  vpc_id         = module.network.vpc_id
  security_tiers = var.security_tiers
  name_prefix    = local.name_prefix
  common_tags    = var.common_tags
}

data "aws_caller_identity" "observer" { provider = aws.readonly }

module "identity" {
  source       = "../../modules/identity"
  providers    = { aws.workload = aws.workload }
  account_id   = data.aws_caller_identity.observer.account_id
  access_roles = var.access_roles
  name_prefix  = local.name_prefix
  common_tags  = var.common_tags
}

resource "aws_s3_bucket" "archive" {
  provider      = aws.archive
  bucket        = lower("${random_pet.scope.id}-${var.environment}-artifact-archive")
  force_destroy = true
  tags          = merge(var.common_tags, { Name = "${local.name_prefix}-archive", Region = var.archive.region })
}

resource "aws_s3_object" "manifest" {
  provider     = aws.archive
  bucket       = aws_s3_bucket.archive.id
  key          = var.archive.object_key
  content      = jsonencode({ exercise = "lab-01", environment = var.environment, owner_account = data.aws_caller_identity.observer.account_id })
  content_type = "application/json"
}

resource "aws_s3_bucket" "state_vault" {
  provider      = aws.network
  bucket        = "tfpro-lab01-state-vault"
  force_destroy = true
  tags          = merge(var.common_tags, { Name = "tfpro-lab01-state-vault" })
}
