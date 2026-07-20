resource "aws_s3_bucket" "assets" {
  bucket = "${var.assets_bucket_name}-replacement"
  tags   = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = var.logs_bucket_name
  tags   = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}

module "content" {
  source = "./modules/content"

  bucket_name = aws_s3_bucket.assets.id
  tags        = local.common_tags
}

resource "aws_s3_object" "retained" {
  bucket  = aws_s3_bucket.assets.id
  key     = "retained.txt"
  content = "KEEP-ME"
  tags    = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_object" "seeded" {
  for_each = local.seed_objects

  bucket  = aws_s3_bucket.assets.id
  key     = each.value.key
  content = each.value.content
  tags    = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_object" "new" {
  bucket  = aws_s3_bucket.assets.id
  key     = "new.txt"
  content = "Success"
  tags    = local.common_tags
}

resource "aws_iam_user" "members" {
  for_each = local.members

  name = each.value
  path = "/tfpro-sim/"
  tags = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_security_group" "application" {
  name        = "${var.name_prefix}-application"
  description = "Temporary description"
  vpc_id      = "vpc-00000000000000000"
  tags        = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "application" {
  for_each = local.ingress_rules

  security_group_id = aws_security_group.application.id
  cidr_ipv4         = each.value.cidr
  from_port         = each.value.from_port
  ip_protocol       = each.value.protocol
  to_port           = each.value.to_port
  description       = each.value.description
  tags              = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}
