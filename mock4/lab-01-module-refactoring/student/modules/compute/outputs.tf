output "instance_inventory" {
  value = {
    for key, instance in aws_instance.executor : key => {
      id          = instance.id
      subnet_key  = var.instances[key].subnet_key
      description = var.instances[key].description
    }
  }
}
