resource "aws_security_group" "challenge_5" {
  for_each = toset(["app-1-sg", "app-2-sg"])

  name   = each.value
  vpc_id = data.aws_vpc.challenge_5.id
}
