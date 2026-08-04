terraform {
  required_version = "= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.80.0"
    }
  }
}

data "aws_ami" "this" {
  filter {
    name   = "image-id"
    values = ["ami-024f768332f0"]
  }
}


resource "aws_instance" "this" {
  ami                  = data.aws_ami.this.id
  instance_type        = "t2.micro"
  # iam_instance_profile = aws_iam_instance_profile.test_profile.name
iam_instance_profile = var.name
}
