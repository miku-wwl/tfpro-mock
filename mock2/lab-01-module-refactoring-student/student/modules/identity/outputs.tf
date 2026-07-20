output "instance_profile_name" {
  value = aws_iam_instance_profile.workload.name
}

output "role_name" {
  value = aws_iam_role.workload.name
}
