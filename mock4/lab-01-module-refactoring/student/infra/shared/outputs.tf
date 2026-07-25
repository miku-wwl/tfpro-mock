output "subnet_ids" {
  value = module.network.subnet_ids
}

output "normalized_node_map" {
  value = local.normalized_node_map
}

output "shared_contract" {
  value = {
    name_prefix = random_pet.label.id
    subnet_ids  = module.network.subnet_ids
    sg_ids      = module.security.security_group_ids
  }
}
