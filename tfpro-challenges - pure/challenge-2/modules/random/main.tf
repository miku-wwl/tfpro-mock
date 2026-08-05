resource "random_pet" "this" {}

output "id" {
  value = random_pet.this.id
}