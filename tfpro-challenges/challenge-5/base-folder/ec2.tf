data "aws_subnet" "challenge_5" {
  for_each = toset(["subnet-subnet1", "subnet-subnet2"])

  vpc_id = data.aws_vpc.challenge_5.id

  filter {
    name   = "tag:Name"
    values = [each.value]
  }
}

resource "aws_instance" "challenge_5" {
  for_each = data.aws_subnet.challenge_5

  ami           = "ami-df5de72bdb3b"
  instance_type = "t2.micro"
  subnet_id     = each.value.id
}
