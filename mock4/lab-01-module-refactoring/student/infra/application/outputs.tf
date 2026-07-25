output "instance_inventory" {
  value = module.compute.instance_inventory
}

output "instance_profile_name" {
  value = module.identity.instance_profile_name
}
