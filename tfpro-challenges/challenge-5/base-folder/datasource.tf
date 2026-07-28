data "aws_vpc" "challenge_5" {
  filter {
    name   = "tag:Name"
    values = ["challenge-5-vpc"]
  }
}

data "aws_subnets" "challenge_5" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.challenge_5.id]
  }

  filter {
    name = "tag:Name"
    values = [
      "subnet-subnet1",
      "subnet-subnet2",
    ]
  }
}

output "subnet_ids" {
  value = data.aws_subnets.challenge_5.ids
}
