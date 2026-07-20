locals {
  common_tags = {
    Environment = "simulation"
    ManagedBy   = "student"
    Exercise    = "state-recovery"
  }

  members = {
    alpha       = "${var.name_prefix}-alpha"
    beta        = "${var.name_prefix}-beta"
    "gamma-ops" = "${var.name_prefix}-gamma"
  }

  seed_objects = {
    "cold-path" = { key = "cold-path.txt", content = "COLD" }
    "warm-up"   = { key = "warm-up.txt", content = "WARM" }
  }

  ingress_rules = {
    "https-public" = {
      cidr        = "0.0.0.0/0"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS from everywhere"
    }
    "ops-vpn" = {
      cidr        = "10.42.0.0/16"
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      description = "Operations VPN"
    }
  }
}
