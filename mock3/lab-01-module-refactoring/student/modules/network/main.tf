resource "aws_vpc" "core" {
  provider             = aws.network
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-core"
  })
}

resource "aws_subnet" "slice" {
  provider = aws.network
  count    = length(var.subnet_cidrs)

  vpc_id            = aws_vpc.core.id
  cidr_block        = var.subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-slice-${count.index + 1}"
  })
}
