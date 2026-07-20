resource "aws_launch_template" "workload" {
  provider = aws.identity

  name          = "lab02-nimbus-template"
  image_id      = "ami-00000000000000001"
  instance_type = "t3.nano"
}

resource "aws_autoscaling_group" "pool" {
  provider = aws.identity

  name               = "lab02-nimbus-pool"
  availability_zones = ["us-east-1a"]
  desired_capacity   = var.desired_capacity
  min_size           = 1
  max_size           = 2

  launch_template {
    id      = aws_launch_template.workload.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = all
  }

  tag {
    key                 = "PracticeLab"
    value               = "provider-matrix-recovery"
    propagate_at_launch = true
  }
}
