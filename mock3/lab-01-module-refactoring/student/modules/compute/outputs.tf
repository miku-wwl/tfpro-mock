output "instance_ids" {
  value = {
    for name, instance in aws_instance.workload : name => instance.id
  }
}
