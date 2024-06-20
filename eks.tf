module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name = "eks-05"
  cluster_version = "1.29"
  cluster_ip_family = "ipv4"
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true
  create_cluster_security_group = false
  cluster_security_group_id = aws_security_group.cluster_vpc_secruity_group.id
  vpc_id = aws_vpc.cluster_vpc.id
  subnet_ids = values(aws_subnet.subnets)[*].id
  create_iam_role = false
  iam_role_arn = aws_iam_role.eks_role.arn

  access_entries = {
    dev-nex = {
      principal_arn = "arn:aws:iam::905418203195:user/dev-nex"
      type          = "STANDARD",
    }
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
      iam_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
  }

  authentication_mode = "API_AND_CONFIG_MAP"

  eks_managed_node_groups = {
    eks-05-mng = {
      max_size = 6
      min_size = 3
      desired_size = 3
      instance_types = ["c3.large"]
      capacity_type = "ON_DEMAND"
      create_iam_role = false
      vpc_id = aws_vpc.cluster_vpc.id
      subnet_ids = values(aws_subnet.subnets)[*].id
      iam_role_arn = aws_iam_role.eks_node_role.arn
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "dev"
    Terraform  = "true"
  }

  depends_on = [aws_security_group.cluster_vpc_secruity_group, aws_vpc.cluster_vpc, aws_subnet.subnets, aws_iam_role.eks_role, aws_iam_role.eks_node_role]
}

module "ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "${module.eks.cluster_name}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}