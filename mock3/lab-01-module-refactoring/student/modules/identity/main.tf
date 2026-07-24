data "aws_iam_policy_document" "provider_assume" {
  provider = aws.workload

  statement {
    sid     = "LocalPracticeAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
  }
}

data "aws_iam_policy_document" "ec2_assume" {
  provider = aws.workload

  statement {
    sid     = "Ec2WorkloadTrust"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "access_boundary" {
  provider = aws.workload
  for_each = var.access_roles

  name               = each.value.role_name
  assume_role_policy = data.aws_iam_policy_document.provider_assume.json

  tags = merge(var.common_tags, {
    Profile         = each.value.profile_name
    PermissionScope = each.value.permission_scope
  })
}

resource "aws_iam_role" "workload" {
  provider = aws.workload

  name               = "${var.name_prefix}-node-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-node-role"
  })
}

resource "aws_iam_instance_profile" "workload" {
  provider = aws.workload

  name = "${var.name_prefix}-node-profile"
  role = aws_iam_role.workload.name

  tags = var.common_tags
}
