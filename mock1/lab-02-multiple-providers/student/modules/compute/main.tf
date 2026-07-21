terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70.0"

      configuration_aliases = [aws.compute]
    }
  }
}

resource "aws_launch_template" "node_profile" {
  provider      = aws.compute
  name          = "lab02-runner-template"
  image_id      = "ami-00000000000000000"
  instance_type = "t3.nano"
}

resource "aws_autoscaling_group" "pool" {
  provider           = aws.compute
  name               = "lab02-runner-pool"
  availability_zones = ["us-east-1a"]
  desired_capacity   = 2
  min_size           = 1
  max_size           = 2

  launch_template {
    id      = aws_launch_template.node_profile.id
    version = "$Latest"
  }

  tag {
    key                 = "Purpose"
    value               = "tfpro-lab02"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.pool.name
}
