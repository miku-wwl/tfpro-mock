data "aws_iam_policy_document" "workload_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "workload" {
  name               = "${var.name_seed}-runtime-role"
  assume_role_policy = data.aws_iam_policy_document.workload_assume.json

  tags = {
    Name = "${var.name_seed}-runtime-role"
    Lab  = "tfpro-state-addresses"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_instance_profile" "workload" {
  name = "${var.name_seed}-runtime-profile"
  role = aws_iam_role.workload.name

  lifecycle {
    prevent_destroy = true
  }
}
