resource "aws_vpc" "harbor" {
  cidr_block           = var.network.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = var.network.tags
}

resource "aws_subnet" "zones" {
  count = length(var.subnets)

  vpc_id            = aws_vpc.harbor.id
  cidr_block        = var.subnets[count.index].cidr_block
  availability_zone = var.subnets[count.index].availability_zone
  tags               = var.subnets[count.index].tags
}
