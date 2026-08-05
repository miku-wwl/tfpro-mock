resource "aws_instance" "this" {
  for_each = toset(data.aws_subnets.example.ids)

  ami           = "ami-024f768332f0"
  instance_type = "t3.micro"
  subnet_id     = each.value
}