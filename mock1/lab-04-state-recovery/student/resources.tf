locals {
  # One key does not match the required final state address.
  users = {
    alpha = "${var.lab_prefix}-alpha"
    beta  = "${var.lab_prefix}-beta"
    gama  = "${var.lab_prefix}-gamma"
  }

  ingress_rules = {
    api = {
      description = "API access from service network"
      cidr        = "10.84.0.0/16"
      port        = 8080
    }
    ops = {
      description = "Operations access from admin network"
      cidr        = "10.42.0.0/16"
      port        = 8443
    }
  }
}

resource "aws_s3_bucket" "assets" {
  # This physical name does not match the existing assets bucket.
  bucket        = "${var.lab_prefix}-asset-store"
  force_destroy = false

  tags = {
    Name      = "${var.lab_prefix}-asset-store"
    Purpose   = "artifact-storage"
    ManagedBy = "terraform"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket        = "${var.lab_prefix}-logs"
  force_destroy = false

  tags = {
    Name      = "${var.lab_prefix}-logs"
    Purpose   = "central-logs"
    ManagedBy = "terraform"
  }
}

resource "aws_s3_object" "base" {
  bucket       = "${var.lab_prefix}-assets"
  key          = "base.txt"
  content      = "BASE-CONTENT"
  content_type = "text/plain"
}

resource "aws_s3_object" "retained" {
  bucket       = "${var.lab_prefix}-assets"
  key          = "retained.txt"
  content      = "KEEP-ME"
  content_type = "text/plain"
}

resource "aws_iam_user" "members" {
  for_each = local.users

  name = each.value
  path = "/tfpro-lab04/"

  tags = {
    Role      = each.key
    ManagedBy = "terraform"
  }
}

resource "aws_security_group" "application" {
  name        = "${var.lab_prefix}-application"
  description = "Application access controls for Terraform state recovery"
  vpc_id      = data.aws_vpc.scaffold.id

  tags = {
    Name      = "${var.lab_prefix}-application"
    Purpose   = "recovered-lab"
    ManagedBy = "terraform"
  }
}

resource "aws_security_group_rule" "inbound" {
  for_each = local.ingress_rules

  type              = "ingress"
  description       = each.value.description
  security_group_id = aws_security_group.application.id
  protocol          = "tcp"
  from_port         = each.value.port
  to_port           = each.value.port
  cidr_blocks       = [each.value.cidr]
}
