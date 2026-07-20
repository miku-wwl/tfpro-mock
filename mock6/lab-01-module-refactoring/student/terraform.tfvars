network_layout = {
  vpc_cidr           = "10.58.0.0/16"
  subnet_cidrs       = ["10.58.11.0/24", "10.58.22.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
}

operator_cidrs = [
  "198.51.100.0/28",
  "203.0.113.64/28"
]

node_catalog = {
  gateway = {
    subnet_index    = 0
    security_groups = ["edge", "service"]
    instance_type   = "t3.nano"
  }
  processor = {
    subnet_index    = 1
    security_groups = ["service", "operations"]
    instance_type   = "t3.nano"
  }
}

business_metadata = {
  owner       = "platform-foundation"
  cost_centre = "cc-4821"
  service     = "northstar-relay"
  stage       = "simulation"
}
