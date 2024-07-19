provider "helm" {
  alias = "eks-helm"
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--profile", var.aws_profile.profile]
      command     = "aws"
    }
  }
}

resource "helm_release" "postgresql-ha" {
  provider   = helm.eks-helm
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql-ha"
  name       = "cve-db"
  namespace  = var.namespaces["subscriber"].name
  values     = ["${file("values/postgresql.yaml")}"]

  set {
    name  = "global.storageClass"
    value = kubernetes_storage_class.storage_class.metadata[0].name
  }

  depends_on = [kubernetes_namespace.namespace["subscriber"], kubernetes_storage_class.storage_class]
}

resource "helm_release" "kafka-ha" {
  provider   = helm.eks-helm
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kafka"
  name       = "cve-kafka"
  namespace  = var.namespaces["kafka"].name
  values     = ["${file("values/kafka.yaml")}"]

  set {
    name  = "global.storageClass"
    value = kubernetes_storage_class.storage_class.metadata[0].name
  }

  depends_on = [kubernetes_namespace.namespace["kafka"], kubernetes_storage_class.storage_class]
}

resource "helm_release" "autoscaler" {
  repository          = var.autoscaler.repository
  repository_username = var.autoscaler.repository_username
  repository_password = var.autoscaler.repository_password
  name                = "cluster-autoscaler"
  chart               = var.autoscaler.chart
  namespace           = var.namespaces["autoscaler"].name
  values              = ["${file("values/autoscaler.yaml")}"]

  depends_on = [kubernetes_namespace.namespace["autoscaler"]]
}