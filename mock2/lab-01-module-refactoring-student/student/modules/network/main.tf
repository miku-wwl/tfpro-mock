resource "aws_vpc" "fabric" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = "${var.name_seed}-vpc"
    Lab       = "tfpro-state-addresses"
    ManagedBy = "terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_subnet" "segment" {
  for_each = var.segment_specs

  vpc_id            = aws_vpc.fabric.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name       = "${var.name_seed}-${each.key}"
    SegmentKey = each.key
    Lab        = "tfpro-state-addresses"
  }

  lifecycle {
    prevent_destroy = true
  }
}
