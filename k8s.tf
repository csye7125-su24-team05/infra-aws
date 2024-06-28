provider "kubernetes" {
  alias                  = "k8s"
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--profile", var.aws_profile.profile]
    command     = "aws"
  }
}

resource "kubernetes_namespace" "namespace" {
  provider = kubernetes.k8s
  for_each = var.namespaces
  metadata {
    name = each.value.name
  }

  depends_on = [module.eks]
}

resource "kubernetes_storage_class" "storage_class" {
  provider = kubernetes.k8s
  metadata {
    name = var.storage_class.name
  }
  storage_provisioner = var.storage_class.storage_provisioner
  parameters = {
    type      = var.storage_class.parameters.type
    iopsPerGB = var.storage_class.parameters.iopsPerGB
    encrypted = var.storage_class.parameters.encrypted
    kmsKeyId  = aws_kms_key.ebs_kms_key.arn
  }

  depends_on = [module.eks, aws_kms_key.ebs_kms_key]
}