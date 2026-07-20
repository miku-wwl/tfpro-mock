output "instance_profile_name" {
  value = aws_iam_instance_profile.runtime_profile.name
}

output "role_name" {
  value = aws_iam_role.runtime_role.name
}
