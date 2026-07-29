data "aws_vpc" "central" {
  filter {
    name   = "tag:Name"
    values = ["central-vpc"]
  }
}

data "aws_subnet" "subnets" {
  for_each = toset(["app-subnet", "database-subnet", "central-subnet"])

  vpc_id = data.aws_vpc.central.id

  filter {
    name   = "tag:Name"
    values = [each.value]
  }
}

output "subnet_ids" {
  value = {
    for subnet_name, subnet in data.aws_subnet.subnets : subnet_name => subnet.id
  }
}
