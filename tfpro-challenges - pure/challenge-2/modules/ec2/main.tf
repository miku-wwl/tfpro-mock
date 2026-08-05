data "aws_ami" "this" {
  filter {
    name   = "image-id"
    values = ["ami-024f768332f0"]
  }
}

resource "aws_instance" "this" {
  ami                  = data.aws_ami.this.id
  instance_type        = "t2.micro"
  iam_instance_profile = var.name
}
