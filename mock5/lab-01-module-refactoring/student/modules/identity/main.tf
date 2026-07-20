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
  name               = substr("${var.name_stem}-${var.shared_naming.token}-runtime", 0, 64)
  assume_role_policy = data.aws_iam_policy_document.runtime_assume.json
}

resource "aws_iam_instance_profile" "runtime" {
  name = substr("${var.name_stem}-${var.shared_naming.token}-profile", 0, 128)
  role = aws_iam_role.runtime.name
}
