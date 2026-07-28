variable "subnet_ids" {
  type = map(string)
}

resource "aws_instance" "challenge_5" {
  for_each      = var.subnet_ids
  ami           = "ami-df5de72bdb3b"
  instance_type = "t2.micro"
  subnet_id     = each.value
}
