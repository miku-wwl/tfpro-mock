resource "aws_vpc" "platform" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "${var.name_stem}-vpc" }
}

resource "aws_subnet" "segment" {
  count = length(var.segment_definitions)

  vpc_id            = aws_vpc.platform.id
  cidr_block        = var.segment_definitions[count.index].cidr_block
  availability_zone = var.segment_definitions[count.index].availability_zone
  tags = {
    Name       = "${var.name_stem}-${var.segment_definitions[count.index].key}"
    SegmentKey = var.segment_definitions[count.index].key
  }
}
