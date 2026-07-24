environment = "exam"

address_space = {
  cidr               = "10.42.0.0/16"
  subnet_cidrs       = ["10.42.11.0/24", "10.42.22.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
}

security_tiers = ["gateway", "services", "operations"]

archive = {
  region     = "us-west-2"
  object_key = "manifests/platform.json"
}

access_roles = {
  network = {
    role_name        = "Lab01NetworkOperator"
    profile_name     = "fabric-admin"
    permission_scope = "network"
  }
  workload = {
    role_name        = "Lab01WorkloadOperator"
    profile_name     = "workload-admin"
    permission_scope = "workload"
  }
  archive = {
    role_name        = "Lab01ArchiveOperator"
    profile_name     = "archive-admin"
    permission_scope = "archive"
  }
  readonly = {
    role_name        = "Lab01ReadOnlyObserver"
    profile_name     = "observer"
    permission_scope = "readonly"
  }
}

common_tags = {
  Exercise = "tfpro-lab-01"
  Owner    = "platform-practice"
}
