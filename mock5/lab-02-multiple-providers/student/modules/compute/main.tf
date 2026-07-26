resource "aws_launch_template" "node_template" {
  provider      = aws.compute
  name_prefix   = "lab02-capacity-template-"
  image_id      = "ami-327e5696"
  instance_type = "t3.nano"
}

resource "aws_autoscaling_group" "capacity_pool" {
  provider           = aws.compute
  name               = "lab02-capacity-pool"
  availability_zones = ["us-east-1a"]
  desired_capacity   = 2
  min_size           = 1
  max_size           = 3

  launch_template {
    id      = aws_launch_template.node_template.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}
