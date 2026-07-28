resource "aws_launch_template" "this" {
  name          = "terraform-launch-template"
  image_id      = "ami-df5de72bdb3b"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "dev" {
  availability_zones = ["us-east-1a", "us-east-1b"]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Team"
    value               = "SRE"
    propagate_at_launch = true
  }
}
