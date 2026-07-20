data "aws_iam_policy_document" "compute_trust" {
  statement {
    sid     = "NorthstarComputeTrust"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "runtime_role" {
  name               = "${var.naming_context.prefix}-${var.naming_context.environment}-runtime"
  assume_role_policy = data.aws_iam_policy_document.compute_trust.json
  tags               = var.resource_tags
}

resource "aws_iam_instance_profile" "runtime_profile" {
  name = "${var.naming_context.prefix}-${var.naming_context.environment}-profile"
  role = aws_iam_role.runtime_role.name
}
