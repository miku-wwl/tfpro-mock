resource "random_pet" "release_marker" {
  length    = 2
  separator = "-"
}

resource "aws_vpc" "relay_fabric" {
  cidr_block           = var.network_layout.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "northstar-${random_pet.release_marker.id}-fabric"
  }
}

resource "aws_subnet" "relay_segment" {
  count = length(var.network_layout.subnet_cidrs)

  vpc_id                  = aws_vpc.relay_fabric.id
  cidr_block              = var.network_layout.subnet_cidrs[count.index]
  availability_zone       = var.network_layout.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "northstar-${random_pet.release_marker.id}-segment-${count.index + 1}"
    Tier = count.index == 0 ? "ingress" : "processing"
  }
}

resource "aws_security_group" "boundary" {
  for_each = local.security_profiles

  name        = "northstar-${random_pet.release_marker.id}-${each.key}"
  description = each.value.description
  vpc_id      = aws_vpc.relay_fabric.id

  tags = {
    Name     = "northstar-${random_pet.release_marker.id}-${each.key}"
    Boundary = each.key
  }
}

resource "aws_vpc_security_group_ingress_rule" "edge_tls" {
  security_group_id = aws_security_group.boundary["edge"].id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  description       = "Public TLS traffic"
}

resource "aws_vpc_security_group_ingress_rule" "service_from_edge" {
  security_group_id            = aws_security_group.boundary["service"].id
  referenced_security_group_id = aws_security_group.boundary["edge"].id
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080
  description                  = "Relay traffic from the edge boundary"
}

resource "aws_vpc_security_group_ingress_rule" "operations_ssh" {
  for_each = var.operator_cidrs

  security_group_id = aws_security_group.boundary["operations"].id
  cidr_ipv4         = each.value
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  description       = "Operator access"
}

resource "aws_vpc_security_group_ingress_rule" "service_metrics" {
  security_group_id            = aws_security_group.boundary["service"].id
  referenced_security_group_id = aws_security_group.boundary["operations"].id
  from_port                    = 9090
  ip_protocol                  = "tcp"
  to_port                      = 9090
  description                  = "Metrics collection from operations"
}

resource "aws_vpc_security_group_egress_rule" "edge_to_service" {
  security_group_id            = aws_security_group.boundary["edge"].id
  referenced_security_group_id = aws_security_group.boundary["service"].id
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080
  description                  = "Forward relay traffic to processing"
}

resource "aws_vpc_security_group_egress_rule" "service_outbound" {
  security_group_id = aws_security_group.boundary["service"].id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Service outbound access"
}

data "aws_iam_policy_document" "compute_trust" {
  statement {
    sid     = "NorthstarComputeTrust"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "runtime_role" {
  name               = "northstar-${random_pet.release_marker.id}-runtime"
  assume_role_policy = data.aws_iam_policy_document.compute_trust.json

  tags = {
    Name = "northstar-${random_pet.release_marker.id}-runtime"
  }
}

resource "aws_iam_instance_profile" "runtime_profile" {
  name = "northstar-${random_pet.release_marker.id}-profile"
  role = aws_iam_role.runtime_role.name
}

resource "aws_s3_bucket" "artifact_store" {
  bucket        = "northstar-${random_pet.release_marker.id}-artifacts"
  force_destroy = true

  tags = {
    Name = "northstar-${random_pet.release_marker.id}-artifacts"
  }
}

resource "aws_s3_object" "relay_manifest" {
  bucket       = aws_s3_bucket.artifact_store.id
  key          = "manifests/relay.json"
  content_type = "application/json"
  content = jsonencode({
    service = var.business_metadata.service
    stage   = var.business_metadata.stage
    release = random_pet.release_marker.id
  })
}

resource "aws_s3_bucket" "state_archive" {
  bucket        = "northstar-${random_pet.release_marker.id}-tfstate"
  force_destroy = true

  tags = {
    Name    = "northstar-${random_pet.release_marker.id}-tfstate"
    Purpose = "Terraform state"
  }
}

resource "aws_instance" "relay_node" {
  for_each = var.node_catalog

  ami                    = "ami-0f1a2b3c4d5e6f701"
  instance_type          = each.value.instance_type
  subnet_id              = aws_subnet.relay_segment[each.value.subnet_index].id
  vpc_security_group_ids = [for group_name in each.value.security_groups : aws_security_group.boundary[group_name].id]
  iam_instance_profile   = aws_iam_instance_profile.runtime_profile.name

  tags = {
    Name = "northstar-${random_pet.release_marker.id}-${each.key}"
    Role = each.key
  }
}
