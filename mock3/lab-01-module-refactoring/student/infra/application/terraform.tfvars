environment = "exam"

workloads = {
  blue = {
    subnet_index   = 0
    instance_type  = "t3.micro"
    security_tiers = ["gateway", "services"]
  }
  amber = {
    subnet_index   = 1
    instance_type  = "t3.micro"
    security_tiers = ["services", "operations"]
  }
}

common_tags = {
  Exercise = "tfpro-lab-01"
  Owner    = "platform-practice"
}
