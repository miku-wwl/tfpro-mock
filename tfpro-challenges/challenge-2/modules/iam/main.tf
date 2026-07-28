variable "pet_id" { type = string }
variable "org_name" { type = string }

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "test_role" {
  name               = "ec2-iam-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.test_role.name
}

resource "aws_iam_user" "lb" {
  count = 3
  name  = "${var.pet_id}-${var.org_name}-${count.index}"
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.test_profile.name
}

resource "aws_iam_user_policy" "lb_ro" {
  name  = "ec2-describe-policy"
  count = 3
  user  = aws_iam_user.lb[count.index].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["ec2:Describe*"]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}
