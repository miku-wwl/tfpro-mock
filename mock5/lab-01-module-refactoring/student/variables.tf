variable "aws_region" {
  type        = string
  description = "AWS-compatible region used by LocalStack."
  default     = "us-east-1"
}

variable "localstack_endpoint" {
  type        = string
  description = "LocalStack edge endpoint used by the host Terraform process."
  default     = "http://localhost:4566"
}

variable "lab_identity" {
  type = object({
    project_code = string
    environment  = string
    owner        = string
  })
  default = {
    project_code = "orion-yard"
    environment  = "practice"
    owner        = "platform-team"
  }
}

variable "mandatory_tag_keys" {
  type        = set(string)
  description = "Keys that must be projected into provider default tags."
  default     = ["Project", "Environment", "Owner"]
}

variable "segment_definitions" {
  type = list(object({
    key               = string
    cidr_block        = string
    availability_zone = string
  }))
  default = [
    {
      key               = "north"
      cidr_block        = "10.42.10.0/24"
      availability_zone = "us-east-1a"
    },
    {
      key               = "south"
      cidr_block        = "10.42.20.0/24"
      availability_zone = "us-east-1b"
    }
  ]
}

variable "security_tiers" {
  type = map(object({
    description = string
  }))
  default = {
    edge  = { description = "Public entry tier" }
    store = { description = "Internal data tier" }
    ops   = { description = "Operations tier" }
  }
}

variable "ingress_rules" {
  type = map(object({
    target_tier = string
    source_cidr = optional(string)
    source_tier = optional(string)
    port        = number
    protocol    = string
    description = string
  }))
  default = {
    edge_http = {
      target_tier = "edge"
      source_cidr = "0.0.0.0/0"
      port        = 8080
      protocol    = "tcp"
      description = "Public application traffic"
    }
    edge_tls = {
      target_tier = "edge"
      source_cidr = "0.0.0.0/0"
      port        = 8443
      protocol    = "tcp"
      description = "Public encrypted traffic"
    }
    store_from_edge = {
      target_tier = "store"
      source_tier = "edge"
      port        = 5432
      protocol    = "tcp"
      description = "Edge to data service"
    }
    ops_from_edge = {
      target_tier = "ops"
      source_tier = "edge"
      port        = 9100
      protocol    = "tcp"
      description = "Edge metrics"
    }
    ops_from_store = {
      target_tier = "ops"
      source_tier = "store"
      port        = 9100
      protocol    = "tcp"
      description = "Store metrics"
    }
    edge_admin = {
      target_tier = "edge"
      source_cidr = "10.42.0.0/16"
      port        = 22
      protocol    = "tcp"
      description = "Private administration"
    }
    store_health = {
      target_tier = "store"
      source_tier = "ops"
      port        = 9090
      protocol    = "tcp"
      description = "Operations health checks"
    }
  }
}

variable "workload_roles" {
  type = map(object({
    segment_index = number
    security_tier = string
    instance_type = string
  }))
  default = {
    gateway = {
      segment_index = 0
      security_tier = "edge"
      instance_type = "t3.micro"
    }
    processor = {
      segment_index = 1
      security_tier = "store"
      instance_type = "t3.micro"
    }
  }
}

variable "base_ami" {
  type        = string
  description = "Stable emulator AMI identifier."
  default     = "ami-0abc1234def567890"
}

variable "artifact_object_key" {
  type        = string
  description = "Retained S3 object key."
  default     = "manifests/runtime.json"
}
