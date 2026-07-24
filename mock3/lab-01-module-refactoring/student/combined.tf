resource "random_pet" "scope" {
  length = 2
}

data "aws_caller_identity" "observer" {
  provider = aws.readonly
}

data "aws_iam_policy_document" "provider_assume" {
  provider = aws.workload

  statement {
    sid     = "LocalPracticeAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.observer.account_id}:root"]
    }
  }
}

data "aws_iam_policy_document" "ec2_assume" {
  provider = aws.workload

  statement {
    sid     = "Ec2WorkloadTrust"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

locals {
  name_prefix = "${random_pet.scope.id}-${var.environment}"
  archive_manifest = jsonencode({
    exercise      = "lab-01"
    environment   = var.environment
    owner_account = data.aws_caller_identity.observer.account_id
  })
}

resource "aws_vpc" "core" {
  provider             = aws.network
  cidr_block           = var.address_space.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-core"
  })
}

resource "aws_subnet" "slice" {
  provider = aws.network
  count    = length(var.address_space.subnet_cidrs)

  vpc_id            = aws_vpc.core.id
  cidr_block        = var.address_space.subnet_cidrs[count.index]
  availability_zone = var.address_space.availability_zones[count.index]

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-slice-${count.index + 1}"
  })
}

resource "aws_security_group" "tier" {
  provider = aws.network
  for_each = var.security_tiers

  name        = "${local.name_prefix}-${each.key}"
  description = "${each.key} boundary for Terraform Professional practice"
  vpc_id      = aws_vpc.core.id

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-${each.key}"
    Tier = each.key
  })
}

resource "aws_vpc_security_group_ingress_rule" "public_tls" {
  provider = aws.network

  security_group_id = aws_security_group.tier["gateway"].id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Public TLS entry"
}

resource "aws_vpc_security_group_ingress_rule" "gateway_to_services" {
  provider = aws.network

  security_group_id            = aws_security_group.tier["services"].id
  referenced_security_group_id = aws_security_group.tier["gateway"].id
  from_port                    = 8443
  to_port                      = 8443
  ip_protocol                  = "tcp"
  description                  = "Gateway to services"
}

resource "aws_vpc_security_group_ingress_rule" "operations_to_services" {
  provider = aws.network

  security_group_id            = aws_security_group.tier["services"].id
  referenced_security_group_id = aws_security_group.tier["operations"].id
  from_port                    = 9090
  to_port                      = 9090
  ip_protocol                  = "tcp"
  description                  = "Operations metrics access"
}

resource "aws_vpc_security_group_ingress_rule" "operations_to_gateway" {
  provider = aws.network

  security_group_id            = aws_security_group.tier["gateway"].id
  referenced_security_group_id = aws_security_group.tier["operations"].id
  from_port                    = 2200
  to_port                      = 2200
  ip_protocol                  = "tcp"
  description                  = "Operations administrative access"
}

resource "aws_vpc_security_group_egress_rule" "outbound" {
  provider = aws.network
  for_each = var.security_tiers

  security_group_id = aws_security_group.tier[each.key].id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Explicit outbound access for ${each.key}"
}

resource "aws_iam_role" "access_boundary" {
  provider = aws.workload
  for_each = var.access_roles

  name               = each.value.role_name
  assume_role_policy = data.aws_iam_policy_document.provider_assume.json

  tags = merge(var.common_tags, {
    Profile         = each.value.profile_name
    PermissionScope = each.value.permission_scope
  })
}

resource "aws_iam_role" "workload" {
  provider = aws.workload

  name               = "${local.name_prefix}-node-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-node-role"
  })
}

resource "aws_iam_instance_profile" "workload" {
  provider = aws.workload

  name = "${local.name_prefix}-node-profile"
  role = aws_iam_role.workload.name

  tags = var.common_tags
}

resource "aws_instance" "workload" {
  provider = aws.workload
  for_each = var.workloads

  ami                    = "ami-f5a14ea6"
  instance_type          = each.value.instance_type
  subnet_id              = aws_subnet.slice[each.value.subnet_index].id
  vpc_security_group_ids = [for tier in each.value.security_tiers : aws_security_group.tier[tier].id]
  iam_instance_profile   = aws_iam_instance_profile.workload.name

  tags = merge(var.common_tags, {
    Name            = "${local.name_prefix}-${each.key}"
    ObserverAccount = data.aws_caller_identity.observer.account_id
  })
}

resource "aws_s3_bucket" "archive" {
  provider = aws.archive

  bucket        = lower("${random_pet.scope.id}-${var.environment}-artifact-archive")
  force_destroy = true

  tags = merge(var.common_tags, {
    Name   = "${local.name_prefix}-archive"
    Region = var.archive.region
  })
}

resource "aws_s3_object" "manifest" {
  provider = aws.archive

  bucket       = aws_s3_bucket.archive.id
  key          = var.archive.object_key
  content      = local.archive_manifest
  content_type = "application/json"
  etag         = md5(local.archive_manifest)
}

resource "aws_s3_bucket" "state_vault" {
  provider = aws.network

  bucket        = "tfpro-lab01-state-vault"
  force_destroy = true

  tags = merge(var.common_tags, {
    Name = "tfpro-lab01-state-vault"
  })
}
