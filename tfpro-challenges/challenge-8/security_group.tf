resource "aws_security_group" "kplabs" {
  name   = "kplabs-sg"
  vpc_id = data.aws_vpc.central.id
}
