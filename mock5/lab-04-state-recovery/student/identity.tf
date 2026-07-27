locals {
  members = var.iam_user_names
}

resource "aws_iam_user" "members" {
  for_each = local.members
  name     = each.value

  tags = {
    Lab    = "lab-04-state-recovery"
    Member = each.key
  }
}

