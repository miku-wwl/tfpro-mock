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
  # Draft contract issue: the object declares stem, not label.
  name               = "${var.naming.label}-${var.naming.suffix}-runtime"
  assume_role_policy = data.aws_iam_policy_document.runtime_assume.json
  tags               = var.tags
}

resource "aws_iam_instance_profile" "runtime" {
  name = "${var.naming.label}-${var.naming.suffix}-profile"
  role = aws_iam_role.runtime.name
}
