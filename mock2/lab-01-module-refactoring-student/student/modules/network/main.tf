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
  count = length(var.segment_specs)

  vpc_id            = aws_vpc.fabric.id
  cidr_block        = var.segment_specs[count.index].cidr
  availability_zone = var.segment_specs[count.index].az

  tags = {
    Name       = "${var.name_seed}-${var.segment_specs[count.index].key}"
    SegmentKey = var.segment_specs[count.index].key
    Lab        = "tfpro-state-addresses"
  }

  lifecycle {
    prevent_destroy = true
  }
}
