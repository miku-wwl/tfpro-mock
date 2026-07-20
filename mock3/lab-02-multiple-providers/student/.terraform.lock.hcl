# This lock file is intentionally inconsistent with versions.tf.
# Repair it with Terraform rather than manually inventing checksums.

provider "registry.terraform.io/hashicorp/aws" {
  version     = "5.82.2"
  constraints = "~> 5.80"
}
