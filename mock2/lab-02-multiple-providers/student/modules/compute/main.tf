resource "aws_launch_template" "capacity_template" {
  provider      = aws.execution
  name_prefix   = "lab02-capacity-"
  image_id      = "ami-00000000000000001"
  instance_type = "t3.nano"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_autoscaling_group" "capacity_group" {
  provider            = aws.execution
  name                = var.group_name
  availability_zones  = ["us-east-1a"]
  desired_capacity    = 2
  min_size            = 0
  max_size            = 2
  suspended_processes = ["Launch"]

  launch_template {
    id      = aws_launch_template.capacity_template.id
    version = "$Latest"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [max_size]
  }
}
