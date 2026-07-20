data "aws_iam_policy_document" "runtime_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "runtime" {
  name               = "${var.name_prefix}-runtime-role"
  assume_role_policy = data.aws_iam_policy_document.runtime_assume.json
}

resource "aws_iam_instance_profile" "runtime" {
  name = "${var.name_prefix}-runtime-profile"
  role = aws_iam_role.runtime.name
}
