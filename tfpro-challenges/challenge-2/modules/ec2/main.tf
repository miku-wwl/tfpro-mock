variable "iam_instance_profile" { type = string }

data "aws_ami" "this" {
  most_recent = true
  owners      = ["000000000000"]
  filter {
    name   = "tag:ec2_vm_manager"
    values = ["docker"]
  }
}

resource "aws_instance" "this" {
  ami                  = data.aws_ami.this.id
  instance_type        = "t2.micro"
  iam_instance_profile = var.iam_instance_profile
}
