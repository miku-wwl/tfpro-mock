locals {
  common_tags = {
    Lab       = "04"
    ManagedBy = "Terraform"
  }

  # The capitalized key is intentionally wrong. The final state address must
  # use members["alpha"].
  member_map = {
    Alpha = var.iam_user_names["alpha"]
    beta  = var.iam_user_names["beta"]
    gamma = var.iam_user_names["gamma"]
  }

  rule_definitions = {
    http = {
      description = "Application HTTP"
      cidr_ipv4   = "10.42.0.0/16"
      port        = 80
    }
    admin = {
      description = "Application administration"
      cidr_ipv4   = "10.99.0.0/16" # intentionally differs from the remote rule
      port        = 8443
    }
  }
}

resource "aws_s3_bucket" "assets" {
  provider = aws.storage

  # This near-match would force replacement after the legacy address is moved.
  bucket = replace(var.asset_bucket_name, "-assets", "-asset")

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-assets"
  })
}

resource "aws_s3_bucket" "logs" {
  provider = aws.storage
  bucket   = var.logs_bucket_name

  tags = merge(local.common_tags, {
    Name        = "${var.name_prefix}-logs"
    Environment = "training" # extra drift after import
  })
}

resource "aws_s3_object" "base" {
  provider     = aws.storage
  bucket       = var.asset_bucket_name
  key          = "base.txt"
  content      = "BASE-CONTENT"
  content_type = "text/plain"
}

resource "aws_s3_object" "retained" {
  provider     = aws.storage
  bucket       = var.asset_bucket_name
  key          = "retained.txt"
  content      = "KEEP-ME"
  content_type = "text/plain"
}

# Add the required managed new.txt object during recovery.

resource "aws_iam_user" "members" {
  provider = aws.identity
  for_each = local.member_map

  name = each.value
  tags = merge(local.common_tags, { Role = lower(each.key) })
}

resource "aws_security_group" "application" {
  provider = aws.network

  name        = var.security_group_name
  description = "Temporary application group" # drift after import
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
    Lab  = "04"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rules" {
  provider = aws.network
  for_each = local.rule_definitions

  security_group_id = aws_security_group.application.id
  description       = each.value.description
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = each.value.port
  ip_protocol       = "tcp"
  to_port           = each.value.port

  tags = merge(local.common_tags, { Name = "${var.name_prefix}-${each.key}" })
}
