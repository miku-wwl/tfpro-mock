variable "aws_region" {
  description = "AWS region used by the LocalStack provider."
  type        = string
  default     = "us-east-1"
}

variable "localstack_endpoint" {
  description = "Single edge endpoint exposed by LocalStack."
  type        = string
  default     = "http://localhost:4566"
}

variable "project_code" {
  description = "Stable project prefix used by all pre-existing resources."
  type        = string
  default     = "harbor-grid"
}

variable "vpc_cidr" {
  description = "CIDR block of the existing VPC."
  type        = string
  default     = "10.42.0.0/16"
}

variable "segment_blueprints" {
  description = "Ordered legacy subnet definitions. The final design must not depend on this order."
  type = list(object({
    key  = string
    cidr = string
    az   = string
  }))

  default = [
    {
      key  = "edge-a"
      cidr = "10.42.10.0/24"
      az   = "us-east-1a"
    },
    {
      key  = "edge-b"
      cidr = "10.42.20.0/24"
      az   = "us-east-1b"
    }
  ]
}

variable "security_groups" {
  description = "Security group catalogue keyed by stable compound names."
  type = map(object({
    description = string
  }))

  default = {
    "web-edge" = {
      description = "Public entry tier"
    }
    "service-core" = {
      description = "Internal service tier"
    }
    "ops-admin" = {
      description = "Administrative access tier"
    }
  }
}

variable "ingress_rules" {
  description = "Existing ingress rules keyed by stable composite identity."
  type = map(object({
    destination = string
    source      = optional(string)
    cidr        = optional(string)
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))

  default = {
    "web-edge|tcp|443|internet" = {
      destination = "web-edge"
      source      = null
      cidr        = "0.0.0.0/0"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "TLS from the public internet"
    }
    "service-core|tcp|8443|web-edge" = {
      destination = "service-core"
      source      = "web-edge"
      cidr        = null
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      description = "Application traffic from the edge tier"
    }
    "service-core|tcp|9100|ops-admin" = {
      destination = "service-core"
      source      = "ops-admin"
      cidr        = null
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      description = "Node metrics from administrative tooling"
    }
    "ops-admin|tcp|22|office" = {
      destination = "ops-admin"
      source      = null
      cidr        = "198.51.100.0/24"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH from the documentation office range"
    }
    "ops-admin|tcp|443|web-edge" = {
      destination = "ops-admin"
      source      = "web-edge"
      cidr        = null
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Administrative callback from the edge tier"
    }
    "web-edge|tcp|8080|service-core" = {
      destination = "web-edge"
      source      = "service-core"
      cidr        = null
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "Health callback from the service tier"
    }
  }
}

variable "instances" {
  description = "Existing compute nodes keyed by stable string addresses."
  type = map(object({
    subnet_key          = string
    security_group_keys = set(string)
    instance_type       = string
  }))

  default = {
    "api-blue" = {
      subnet_key          = "edge-a"
      security_group_keys = ["web-edge", "service-core"]
      instance_type       = "t3.micro"
    }
    "jobs-green" = {
      subnet_key          = "edge-b"
      security_group_keys = ["service-core", "ops-admin"]
      instance_type       = "t3.micro"
    }
  }
}

variable "localstack_ami_id" {
  description = "Synthetic AMI identifier accepted by the LocalStack EC2 emulator."
  type        = string
  default     = "ami-0f00f00f00f00f00f"
}
