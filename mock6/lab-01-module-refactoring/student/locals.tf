locals {
  common_tags = {
    ManagedBy  = "Terraform"
    Owner      = var.business_metadata.owner
    CostCentre = var.business_metadata.cost_centre
    Service    = var.business_metadata.service
    Stage      = var.business_metadata.stage
    Lab        = "final-06-lab-01"
  }

  security_profiles = {
    edge = {
      description = "Public TLS entry boundary"
    }
    service = {
      description = "Internal message-processing boundary"
    }
    operations = {
      description = "Restricted operator boundary"
    }
  }
}
