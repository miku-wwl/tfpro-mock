resource "random_pet" "naming" {
  length    = 2
  separator = "-"
}

resource "aws_vpc" "platform" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.name_stem}-vpc"
  }
}

resource "aws_subnet" "segment" {
  count = length(var.segment_definitions)

  vpc_id            = aws_vpc.platform.id
  cidr_block        = var.segment_definitions[count.index].cidr_block
  availability_zone = var.segment_definitions[count.index].availability_zone

  tags = {
    Name       = "${local.name_stem}-${var.segment_definitions[count.index].key}"
    SegmentKey = var.segment_definitions[count.index].key
  }
}

resource "aws_security_group" "tier" {
  for_each = var.security_tiers

  name        = "${local.name_stem}-${each.key}"
  description = each.value.description
  vpc_id      = aws_vpc.platform.id

  tags = {
    Name = "${local.name_stem}-${each.key}"
    Tier = each.key
  }
}

resource "aws_vpc_security_group_ingress_rule" "path" {
  for_each = var.ingress_rules

  security_group_id            = aws_security_group.tier[each.value.target_tier].id
  cidr_ipv4                    = try(each.value.source_cidr, null)
  referenced_security_group_id = try(aws_security_group.tier[each.value.source_tier].id, null)
  from_port                    = each.value.port
  to_port                      = each.value.port
  ip_protocol                  = each.value.protocol
  description                  = each.value.description
}

data "aws_iam_policy_document" "runtime_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "runtime" {
  name               = substr("${local.name_stem}-${random_pet.naming.id}-runtime", 0, 64)
  assume_role_policy = data.aws_iam_policy_document.runtime_assume.json
}

resource "aws_iam_instance_profile" "runtime" {
  name = substr("${local.name_stem}-${random_pet.naming.id}-profile", 0, 128)
  role = aws_iam_role.runtime.name
}

resource "aws_s3_bucket" "artifacts" {
  bucket = substr(lower("${local.name_stem}-${random_pet.naming.id}-artifacts"), 0, 63)

  tags = {
    Purpose = "retained-artifacts"
  }
}

resource "aws_s3_bucket" "state_store" {
  bucket = "tfpro-lab01-state-archive"

  tags = {
    Purpose = "terraform-state"
  }
}

resource "aws_s3_object" "manifest" {
  bucket       = aws_s3_bucket.artifacts.id
  key          = var.artifact_object_key
  content_type = "application/json"
  content = jsonencode({
    platform_id = aws_vpc.platform.id
    name_token  = random_pet.naming.id
    owner       = var.lab_identity.owner
  })
}

resource "aws_instance" "node" {
  for_each = var.workload_roles

  ami                    = var.base_ami
  instance_type          = each.value.instance_type
  subnet_id              = aws_subnet.segment[each.value.segment_index].id
  vpc_security_group_ids = [aws_security_group.tier[each.value.security_tier].id]
  iam_instance_profile   = aws_iam_instance_profile.runtime.name

  tags = {
    Name = "${local.name_stem}-${random_pet.naming.id}-${each.key}"
    Role = each.key
  }

  depends_on = [aws_vpc_security_group_ingress_rule.path]
}
