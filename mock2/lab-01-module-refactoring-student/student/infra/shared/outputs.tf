output "shared_contract" {
  value = {
    naming_seed          = random_pet.cohort.id
    subnet_ids_by_key    = module.shared.subnet_ids_by_key
    security_group_ids   = module.security.security_group_ids
  }
}

output "state_bucket_name" {
  value = aws_s3_bucket.state_store.id
}
