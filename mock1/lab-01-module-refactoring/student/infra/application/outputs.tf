output "instance_ids" {
  value = module.compute.instance_ids
}

output "iam_role_name" {
  value = module.identity.role_name
}

output "instance_profile_name" {
  value = module.identity.instance_profile_name
}