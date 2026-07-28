resource "random_pet" "this" {}

output "pet_id" {
  value = random_pet.this.id
}
