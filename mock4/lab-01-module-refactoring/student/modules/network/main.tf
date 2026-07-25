resource "aws_vpc" "fabric" {
  cidr_block           = "10.48.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.name_prefix}-fabric" }
}

resource "aws_subnet" "segment" {
  for_each = var.subnets

  vpc_id            = aws_vpc.fabric.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = merge(
    {
      Name       = "${var.name_prefix}-${each.key}"
      SegmentKey = each.key
    },
    each.value.route_label == null ? {} : {
      RouteLabel = each.value.route_label
    }
  )
}
