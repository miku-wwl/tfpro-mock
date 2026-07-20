resource "random_pet" "label" {
  length    = 2
  separator = "-"
}

resource "aws_vpc" "fabric" {
  cidr_block           = "10.48.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${random_pet.label.id}-fabric"
  }
}

resource "aws_subnet" "segment" {
  count = length(var.subnet_specs)

  vpc_id            = aws_vpc.fabric.id
  cidr_block        = var.subnet_specs[count.index].cidr
  availability_zone = var.subnet_specs[count.index].az

  tags = merge(
    {
      Name       = "${random_pet.label.id}-${var.subnet_specs[count.index].key}"
      SegmentKey = var.subnet_specs[count.index].key
    },
    var.subnet_specs[count.index].route_label == null ? {} : {
      RouteLabel = var.subnet_specs[count.index].route_label
    }
  )
}

locals {
  security_group_specs = {
    gateway  = "North-south entry"
    services = "Internal services"
    ops      = "Operations access"
  }

  cidr_rules = {
    gateway_https = {
      destination = "gateway"
      cidr        = "0.0.0.0/0"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Public TLS"
    }
    ops_ssh = {
      destination = "ops"
      cidr        = "10.48.0.0/16"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Administrative shell"
    }
    services_dns = {
      destination = "services"
      cidr        = "10.48.0.0/16"
      from_port   = 53
      to_port     = 53
      protocol    = "udp"
      description = "Internal DNS"
    }
  }

  peer_rules = {
    services_from_gateway = {
      destination = "services"
      source      = "gateway"
      from_port   = 8080
      to_port     = 8081
      protocol    = "tcp"
      description = "Gateway to services"
    }
    ops_from_services = {
      destination = "ops"
      source      = "services"
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      description = "Metrics scraping"
    }
  }
}

resource "aws_security_group" "boundary" {
  for_each = local.security_group_specs

  name        = "${random_pet.label.id}-${each.key}"
  description = each.value
  vpc_id      = aws_vpc.fabric.id

  tags = {
    Name = "${random_pet.label.id}-${each.key}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "cidr" {
  for_each = local.cidr_rules

  security_group_id = aws_security_group.boundary[each.value.destination].id
  cidr_ipv4         = each.value.cidr
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  description       = each.value.description
}

resource "aws_vpc_security_group_ingress_rule" "peer" {
  for_each = local.peer_rules

  security_group_id            = aws_security_group.boundary[each.value.destination].id
  referenced_security_group_id = aws_security_group.boundary[each.value.source].id
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.protocol
  description                  = each.value.description
}

resource "aws_vpc_security_group_egress_rule" "all" {
  for_each = aws_security_group.boundary

  security_group_id = each.value.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Unrestricted lab egress"
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
  name               = "${random_pet.label.id}-runtime-role"
  assume_role_policy = data.aws_iam_policy_document.runtime_assume.json
}

resource "aws_iam_instance_profile" "runtime" {
  name = "${random_pet.label.id}-runtime-profile"
  role = aws_iam_role.runtime.name
}

resource "aws_instance" "executor" {
  for_each = local.enabled_node_map

  ami                    = var.ami_id
  instance_type          = each.value.instance_type
  subnet_id              = aws_subnet.segment[index(var.subnet_specs[*].key, each.value.subnet_key)].id
  vpc_security_group_ids = [aws_security_group.boundary["services"].id]
  iam_instance_profile   = aws_iam_instance_profile.runtime.name

  tags = merge(
    {
      Name        = "${random_pet.label.id}-${each.key}"
      WorkloadKey = each.key
      Priority    = tostring(each.value.priority)
    },
    each.value.team == null ? {} : { Team = each.value.team },
    each.value.description == null ? {} : { Description = each.value.description },
    each.value.tags,
  )
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "${random_pet.label.id}-artifact-vault"
}

resource "aws_s3_object" "manifest" {
  bucket       = aws_s3_bucket.artifacts.id
  key          = "manifests/runtime.txt"
  content      = "namespace=${random_pet.label.id}\nworkloads=${join(",", sort(keys(local.enabled_node_map)))}\n"
  content_type = "text/plain"
}

resource "aws_s3_bucket" "state_store" {
  bucket = "tfpro-lab01-state-nimbus"
}
