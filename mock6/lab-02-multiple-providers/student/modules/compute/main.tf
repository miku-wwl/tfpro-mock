resource "aws_launch_template" "runtime" {
  name          = "northstar-batch-runtime"
  image_id      = "ami-0f1e2d3c4b5a69788"
  instance_type = "t3.micro"

  tag_specifications {
    resource_type = "instance"
    tags          = {
      Service = "batch-renderer"
    }
  }
}

resource "aws_autoscaling_group" "pool" {
  name               = "northstar-batch-workers"
  availability_zones = ["us-east-1a"]
  desired_capacity   = 2
  min_size           = 1
  max_size           = 3
  force_delete       = true

  launch_template {
    id      = aws_launch_template.runtime.id
    version = "$Latest"
  }

  tag {
    key                 = "Service"
    value               = "batch-renderer"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [max_size]
  }
}
