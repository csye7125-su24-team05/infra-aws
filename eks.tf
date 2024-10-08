module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  providers = {
    aws = aws.profile
  }

  cluster_name                    = var.eks.cluster_name
  cluster_version                 = var.eks.cluster_version
  cluster_ip_family               = var.eks.cluster_ip_family
  cluster_endpoint_public_access  = var.eks.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.eks.cluster_endpoint_private_access
  create_cluster_security_group   = false
  cluster_security_group_id       = aws_security_group.cluster_vpc_secruity_group.id
  vpc_id                          = aws_vpc.cluster_vpc.id
  subnet_ids                      = values(aws_subnet.subnets)[*].id
  create_iam_role                 = false
  iam_role_arn                    = aws_iam_role.eks_role.arn

  access_entries = var.eks.access_entries

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
        # NETWORK_POLICY_ENFORCING_MODE = "strict"
      })
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  authentication_mode = var.eks.authentication_mode

  eks_managed_node_groups = {
    for key, value in var.eks.eks_managed_node_groups : key => {
      max_size        = value.max_size
      min_size        = value.min_size
      desired_size    = value.desired_size
      instance_types  = value.instance_types
      capacity_type   = value.capacity_type
      create_iam_role = false
      vpc_id          = aws_vpc.cluster_vpc.id
      subnet_ids      = values(aws_subnet.subnets)[*].id
      iam_role_arn    = aws_iam_role.eks_node_role.arn
      ami_type        = try(value.ami_type, null)
      label           = try(value.label, null)
      taints          = try(value.taints, {})
    }
  }

  enable_cluster_creator_admin_permissions = var.eks.enable_cluster_creator_admin_permissions
  node_security_group_additional_rules     = var.eks.node_security_group_additional_rule

  tags = merge(var.tags, var.eks.tags)

  depends_on = [aws_security_group.cluster_vpc_secruity_group, aws_vpc.cluster_vpc, aws_subnet.subnets, aws_iam_role.eks_role, aws_iam_role.eks_node_role]
}