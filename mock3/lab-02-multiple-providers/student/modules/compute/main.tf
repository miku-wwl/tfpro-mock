resource "aws_autoscaling_group" "workload" {
  provider = aws.compute

  name                = "tfpro-lab02-workload"
  desired_capacity    = var.desired_capacity
  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = all
  }

  tag {
    key                 = "Lab"
    value               = "tfpro-lab02"
    propagate_at_launch = true
  }
}
