resource "aws_iam_user" "members" {
  for_each = local.iam_members

  name = each.value.name

  tags = {
    Name = each.value.name
    Role = "recovery-operator"
  }
}
