resource "aws_iam_role" "operator" {
  for_each = local.profile_matrix

  name = each.value.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::000000000000:root"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "terraform_data" "profile_contract" {
  for_each = local.profile_matrix

  input = {
    profile_name   = each.value.profile_name
    module_targets = each.value.module_targets
  }
}

module "compute" {
  source = "./modules/compute"

  desired_capacity = 2
}

module "identity" {
  source = "./modules/identity"
}

module "storage" {
  source = "./modules/storage"
}

data "aws_caller_identity" "current" {}

output "current_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "normalized_profile_matrix" {
  value = local.profile_matrix
}
