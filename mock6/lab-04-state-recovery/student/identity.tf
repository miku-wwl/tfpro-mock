resource "aws_iam_user" "members" {
  for_each = local.member_directory

  name = each.value
  path = "/exam-candidates/"

  tags = {
    Cohort = "recovery"
    Member = trimspace(each.key)
  }

  lifecycle {
    prevent_destroy = true
  }
}
