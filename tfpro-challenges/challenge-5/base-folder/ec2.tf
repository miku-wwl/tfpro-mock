data "aws_subnet" "challenge_5" {
  for_each = toset(["subnet-subnet1", "subnet-subnet2"])

  vpc_id = data.aws_vpc.challenge_5.id

  filter {
    name   = "tag:Name"
    values = [each.value]
  }
}

module "ec2" {
  source = "../modules/ec2"

  subnet_ids = {
    for name, subnet in data.aws_subnet.challenge_5 : name => subnet.id
  }
}
