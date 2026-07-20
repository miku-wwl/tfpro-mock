output "subnet_ids" {
  # Deliberate defect: a map output is treated as a list.
  value = module.network.subnet_ids[0]
}

output "shared_contract" {
  value = {
    name_prefix = random_pet.label.id
    subnet_ids  = module.network.subnet_ids
    sg_ids      = module.security.security_group_ids
  }
}
