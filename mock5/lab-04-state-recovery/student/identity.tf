resource "aws_iam_user" "alpha" {
  name = var.iam_user_names.alpha

  tags = {
    Lab    = "lab-04-state-recovery"
    Member = "alpha"
  }
}

resource "aws_iam_user" "beta" {
  name = var.iam_user_names.beta

  tags = {
    Lab    = "lab-04-state-recovery"
    Member = "beta"
  }
}

resource "aws_iam_user" "gamma" {
  name = var.iam_user_names.gamma

  tags = {
    Lab    = "lab-04-state-recovery"
    Member = "gamma-candidate"
  }
}

locals {
  proposed_member_keys = {
    alpha    = var.iam_user_names.alpha
    beta     = var.iam_user_names.beta
    "gamma " = var.iam_user_names.gamma
  }
}
