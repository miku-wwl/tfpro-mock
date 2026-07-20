resource "aws_vpc" "relay_fabric" {
  cidr_block           = var.network_spec.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.resource_tags, {
    Name = "${var.name_prefix}-fabric"
  })
}

resource "aws_subnet" "relay_segment" {
  count = length(var.network_spec.subnet_cidrs)

  vpc_id                  = aws_vpc.relay_fabric.id
  cidr_block              = var.network_spec.subnet_cidrs[count.index]
  availability_zone       = var.network_spec.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.resource_tags, {
    Name = "${var.name_prefix}-segment-${count.index + 1}"
  })
}
