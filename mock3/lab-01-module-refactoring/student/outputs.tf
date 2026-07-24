output "baseline_resource_ids" {
  description = "Critical identifiers captured by the setup script."
  value = {
    vpc_id              = aws_vpc.core.id
    subnet_ids          = aws_subnet.slice[*].id
    security_group_ids  = { for name, group in aws_security_group.tier : name => group.id }
    instance_ids        = { for name, instance in aws_instance.workload : name => instance.id }
    workload_role_name  = aws_iam_role.workload.name
    instance_profile    = aws_iam_instance_profile.workload.name
    provider_role_arns  = { for name, role in aws_iam_role.access_boundary : name => role.arn }
    archive_bucket_name = aws_s3_bucket.archive.id
    archive_object_key  = aws_s3_object.manifest.key
    remote_state_bucket = aws_s3_bucket.state_vault.id
    observer_account_id = data.aws_caller_identity.observer.account_id
  }
}

output "subnet_ids_by_zone" {
  value = {
    for index, subnet in aws_subnet.slice :
    var.address_space.availability_zones[index] => subnet.id
  }
}

output "security_group_ids" {
  value = { for name, group in aws_security_group.tier : name => group.id }
}
