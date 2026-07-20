locals {
  naming = {
    project     = "driftwood"
    environment = "assessment"
    owner       = "platform-practice"
  }

  subnet_specs = [
    {
      key               = "north"
      name              = "north-zone"
      cidr_block        = "10.42.10.0/24"
      availability_zone = "us-east-1a"
    },
    {
      key               = "south"
      name              = "south-zone"
      cidr_block        = "10.42.20.0/24"
      availability_zone = "us-east-1b"
    }
  ]

  security_groups = {
    edge = {
      description = "Entry tier for client traffic"
    }
    service = {
      description = "Internal application tier"
    }
    ops = {
      description = "Operations access tier"
    }
  }

  ingress_rules = {
    edge_http = {
      target_group = "edge"
      source_group = null
      source_cidr  = "0.0.0.0/0"
      port         = 8080
      protocol     = "tcp"
      description  = "Public application entry"
    }
    service_from_edge = {
      target_group = "service"
      source_group = "edge"
      source_cidr  = null
      port         = 9000
      protocol     = "tcp"
      description  = "Edge to service"
    }
    service_from_ops = {
      target_group = "service"
      source_group = "ops"
      source_cidr  = null
      port         = 9001
      protocol     = "tcp"
      description  = "Operations health access"
    }
    ops_ssh = {
      target_group = "ops"
      source_group = null
      source_cidr  = "10.42.0.0/16"
      port         = 22
      protocol     = "tcp"
      description  = "Administrative SSH"
    }
    edge_from_ops = {
      target_group = "edge"
      source_group = "ops"
      source_cidr  = null
      port         = 8443
      protocol     = "tcp"
      description  = "Operations diagnostics"
    }
  }

  instances = {
    gateway = {
      subnet_key          = "north"
      subnet_index        = 0
      security_group_keys = toset(["edge", "ops"])
      instance_type       = "t3.micro"
    }
    worker = {
      subnet_key          = "south"
      subnet_index        = 1
      security_group_keys = toset(["service"])
      instance_type       = "t3.micro"
    }
  }
}
