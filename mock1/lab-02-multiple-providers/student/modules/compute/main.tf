terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.70.0"
    }
  }
}

# Legacy module-local provider configuration.
provider "aws" {
  alias                       = "identity"
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    autoscaling = "http://localhost:4566"
    ec2         = "http://localhost:4566"
    iam         = "http://localhost:4566"
    s3          = "http://localhost:4566"
    sts         = "http://localhost:4566"
  }
}

resource "aws_launch_template" "node_profile" {
  provider      = aws.identity
  name          = "lab02-runner-template"
  image_id      = "ami-00000000000000000"
  instance_type = "t3.nano"
}

resource "aws_autoscaling_group" "pool" {
  provider           = aws.identity
  name               = "lab02-runner-pool"
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
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
    ignore_changes = [max_size]
  }
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.pool.name
}
