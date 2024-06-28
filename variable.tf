variable "aws_profile" {
  type = object({
    profile = string
    region  = string
  })
}

variable "tags" {
  type = map(string)
}

variable "kms" {
  type = object({
    deletion_window_in_days = number
    tags                    = map(string)
  })

}

variable "subnets" {
  type = map(object({
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))
}

variable "sg_rules" {
  type = map(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "eks" {
  type = object({
    cluster_name                    = string
    cluster_ip_family               = string
    cluster_version                 = string
    cluster_endpoint_private_access = bool
    cluster_endpoint_public_access  = bool
    access_entries = map(object({
      principal_arn = string
      type          = string
      policy_associations = map(object({
        policy_arn = string
        access_scope = object({
          type = string
        })
      }))
    }))
    cluster_addons = map(object({
      most_recent = bool
    }))
    authentication_mode = string
    eks_managed_node_groups = map(object({
      max_size       = number
      min_size       = number
      desired_size   = number
      instance_types = list(string)
      capacity_type  = string
    }))
    enable_cluster_creator_admin_permissions = bool
    tags                                     = map(string)
  })
}

variable "vpc" {
  type = object({
    cidr_block = string
    tags       = map(string)
  })
}

variable "namespaces" {
  type = map(object({
    name = string
  }))
}

variable "storage_class" {
  type = object({
    name                = string
    storage_provisioner = string
    parameters          = map(string)
  })
}