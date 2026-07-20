resource "random_pet" "suffix" {
  length    = 2
  separator = "-"
}

resource "aws_vpc" "harbor" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${local.naming.project}-vpc"
    Environment = local.naming.environment
    Owner       = local.naming.owner
  }
}

resource "aws_subnet" "zones" {
  count = length(local.subnet_specs)

  vpc_id            = aws_vpc.harbor.id
  cidr_block        = local.subnet_specs[count.index].cidr_block
  availability_zone = local.subnet_specs[count.index].availability_zone

  tags = {
    Name        = "${local.naming.project}-${local.subnet_specs[count.index].name}"
    Environment = local.naming.environment
  }
}

resource "aws_security_group" "tiers" {
  for_each = local.security_groups

  name        = "${local.naming.project}-${each.key}-sg"
  description = each.value.description
  vpc_id      = aws_vpc.harbor.id

  tags = {
    Name        = "${local.naming.project}-${each.key}-sg"
    Environment = local.naming.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "links" {
  for_each = local.ingress_rules

  security_group_id            = aws_security_group.tiers[each.value.target_group].id
  referenced_security_group_id = each.value.source_group == null ? null : aws_security_group.tiers[each.value.source_group].id
  cidr_ipv4                    = each.value.source_group == null ? each.value.source_cidr : null
  from_port                    = each.value.port
  to_port                      = each.value.port
  ip_protocol                  = each.value.protocol
  description                  = each.value.description

  tags = {
    Name = "${local.naming.project}-${each.key}"
  }
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
  name               = "${local.naming.project}-${random_pet.suffix.id}-runtime"
  assume_role_policy = data.aws_iam_policy_document.runtime_assume.json

  tags = {
    Environment = local.naming.environment
    Owner       = local.naming.owner
  }
}

resource "aws_iam_instance_profile" "runtime" {
  name = "${local.naming.project}-${random_pet.suffix.id}-profile"
  role = aws_iam_role.runtime.name
}

resource "aws_instance" "nodes" {
  for_each = local.instances

  ami                    = var.ami_id
  instance_type          = each.value.instance_type
  subnet_id              = aws_subnet.zones[each.value.subnet_index].id
  vpc_security_group_ids = [for group_key in each.value.security_group_keys : aws_security_group.tiers[group_key].id]
  iam_instance_profile   = aws_iam_instance_profile.runtime.name

  tags = {
    Name        = "${local.naming.project}-${random_pet.suffix.id}-${each.key}"
    Environment = local.naming.environment
    Role        = each.key
  }
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
