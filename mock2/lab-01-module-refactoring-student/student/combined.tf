locals {
  name_prefix = "${var.project_code}-${random_pet.cohort.id}"
  subnet_index_by_key = {
    for index, segment in var.segment_blueprints : segment.key => index
  }
}

resource "random_pet" "cohort" {
  length    = 2
  separator = "-"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_vpc" "fabric" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name       = "${local.name_prefix}-vpc"
    Lab        = "tfpro-state-addresses"
    ManagedBy  = "terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_subnet" "zone" {
  count = length(var.segment_blueprints)

  vpc_id            = aws_vpc.fabric.id
  cidr_block        = var.segment_blueprints[count.index].cidr
  availability_zone = var.segment_blueprints[count.index].az

  tags = {
    Name       = "${local.name_prefix}-${var.segment_blueprints[count.index].key}"
    SegmentKey = var.segment_blueprints[count.index].key
    Lab        = "tfpro-state-addresses"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_security_group" "tier" {
  for_each = var.security_groups

  name        = "${local.name_prefix}-${each.key}"
  description = each.value.description
  vpc_id      = aws_vpc.fabric.id

  tags = {
    Name    = "${local.name_prefix}-${each.key}"
    TierKey = each.key
    Lab     = "tfpro-state-addresses"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "path" {
  for_each = var.ingress_rules

  security_group_id            = aws_security_group.tier[each.value.destination].id
  referenced_security_group_id = each.value.source == null ? null : aws_security_group.tier[each.value.source].id
  cidr_ipv4                     = each.value.source == null ? each.value.cidr : null
  from_port                     = each.value.from_port
  to_port                       = each.value.to_port
  ip_protocol                   = each.value.protocol
  description                   = each.value.description

  tags = {
    Name = each.key
    Lab  = "tfpro-state-addresses"
  }

  lifecycle {
    prevent_destroy = true
  }
}

data "aws_iam_policy_document" "workload_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "workload" {
  name               = "${local.name_prefix}-runtime-role"
  assume_role_policy = data.aws_iam_policy_document.workload_assume.json

  tags = {
    Name = "${local.name_prefix}-runtime-role"
    Lab  = "tfpro-state-addresses"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_instance_profile" "workload" {
  name = "${local.name_prefix}-runtime-profile"
  role = aws_iam_role.workload.name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_instance" "node" {
  for_each = var.instances

  ami                    = var.localstack_ami_id
  instance_type          = each.value.instance_type
  subnet_id              = aws_subnet.zone[local.subnet_index_by_key[each.value.subnet_key]].id
  vpc_security_group_ids = [for key in sort(tolist(each.value.security_group_keys)) : aws_security_group.tier[key].id]
  iam_instance_profile   = aws_iam_instance_profile.workload.name

  tags = {
    Name     = "${local.name_prefix}-${each.key}"
    NodeKey  = each.key
    Lab      = "tfpro-state-addresses"
  }

  depends_on = [aws_vpc_security_group_ingress_rule.path]

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "artifact_store" {
  bucket = "${local.name_prefix}-artifacts"

  tags = {
    Name = "${local.name_prefix}-artifacts"
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
  bucket = "${local.name_prefix}-state"

  tags = {
    Name = "${local.name_prefix}-state"
    Lab  = "tfpro-state-addresses"
  }

  lifecycle {
    prevent_destroy = true
  }
}
