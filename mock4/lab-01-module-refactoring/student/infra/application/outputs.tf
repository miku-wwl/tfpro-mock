output "instance_inventory" {
  # Deliberate defect: the declared module output name is wrong.
  value = module.compute.instances_by_index
}
