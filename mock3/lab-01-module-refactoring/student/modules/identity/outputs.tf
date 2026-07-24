output "instance_profile_name" {
  value = aws_iam_instance_profile.workload.name
}

output "workload_role_name" {
  value = aws_iam_role.workload.name
}

output "provider_role_arns" {
  value = {
    for name, role in aws_iam_role.access_boundary : name => role.arn
  }
}
