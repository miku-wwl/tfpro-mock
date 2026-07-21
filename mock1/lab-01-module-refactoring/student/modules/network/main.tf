resource "aws_vpc" "harbor" {
  cidr_block           = var.network.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = var.network.tags
}

resource "aws_subnet" "zones" {
  for_each = var.subnets

  vpc_id = aws_vpc.harbor.id

  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags              = each.value.tags
}
