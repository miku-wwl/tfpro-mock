locals {
  all_tags = {
    Project     = var.lab_identity.project_code
    Environment = var.lab_identity.environment
    Owner       = var.lab_identity.owner
    ManagedBy   = "terraform"
  }

  required_tags = {
    for key in var.mandatory_tag_keys : key => local.all_tags[key]
  }

  name_stem = "${var.lab_identity.project_code}-${var.lab_identity.environment}"
}
