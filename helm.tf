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

  depends_on = [kubernetes_namespace.namespace["subscriber"], kubernetes_storage_class.storage_class, module.eks_blueprints_addons, helm_release.istiod]
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

  depends_on = [kubernetes_namespace.namespace["kafka"], kubernetes_storage_class.storage_class, module.eks_blueprints_addons, helm_release.istiod]
}

resource "helm_release" "autoscaler" {
  provider  = helm.eks-helm
  name      = "cluster-autoscaler"
  chart     = "./${var.autoscaler.chart}"
  namespace = var.namespaces["autoscaler"].name
  values    = ["${file("values/autoscaler.yaml")}"]

  depends_on = [kubernetes_namespace.namespace["autoscaler"], null_resource.download_chart]
}


resource "helm_release" "cloudwatch" {
  provider  = helm.eks-helm
  name      = "cluster-cloudwatch"
  chart     = "./${var.cloudwatch.chart}"
  namespace = var.namespaces["amazon-cloudwatch"].name
  values    = ["${file("values/cloudwatch.yaml")}"]

  depends_on = [kubernetes_namespace.namespace["amazon-cloudwatch"], null_resource.download_chart]
}

resource "helm_release" "prometheus" {
  provider  = helm.eks-helm
  name      = "prometheus"
  chart     = "./${var.prometheus.chart}"
  namespace = var.namespaces["prometheus"].name
  values    = ["${file("values/prometheus.yaml")}"]

  depends_on = [kubernetes_namespace.namespace["prometheus"], null_resource.download_chart, helm_release.istiod]
}

resource "helm_release" "istio-base" {
  provider   = helm.eks-helm
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  name       = "istio-base"
  namespace  = var.namespaces["istio-system"].name
  values     = ["${file("values/istio-base.yaml")}"]

  depends_on = [kubernetes_namespace.namespace["istio-system"]]
}

# resource "helm_release" "istio-cni" {
#   provider   = helm.eks-helm
#   repository = "https://istio-release.storage.googleapis.com/charts"
#   chart      = "cni"
#   name       = "istio-cni"
#   namespace  = var.namespaces["istio-system"].name
#   depends_on = [kubernetes_namespace.namespace["istio-system"], helm_release.istio-base]
# }

resource "helm_release" "istiod" {
  provider   = helm.eks-helm
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  name       = "istiod"
  namespace  = var.namespaces["istio-system"].name
  values     = ["${file("values/istiod.yaml")}"]

  depends_on = [kubernetes_namespace.namespace["istio-system"], helm_release.istio-base]
}

resource "helm_release" "istio-ingress" {
  provider         = helm.eks-helm
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  name             = "istio-ingress"
  namespace        = "istio-ingress"
  create_namespace = true
  values           = ["${file("values/istio-ingress.yaml")}"]

  depends_on = [kubernetes_namespace.namespace["istio-system"], helm_release.istiod, module.eks_blueprints_addons]

}

resource "helm_release" "kafka-exporter" {
  provider   = helm.eks-helm
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-kafka-exporter"
  name       = "prometheus-kafka"
  namespace  = var.namespaces["kafka"].name
  values     = ["${file("values/prometheus-kafka-exporter.yaml")}"]
  depends_on = [kubernetes_namespace.namespace["kafka"], module.eks_blueprints_addons, helm_release.kafka-ha]
}

locals {
  name                = basename(path.cwd)
  istio_chart_url     = "https://istio-release.storage.googleapis.com/charts"
  istio_chart_version = "1.20.2"

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.16"

  providers = {
    aws = aws.profile
    helm = helm.eks-helm
  }

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_external_dns                   = true
  enable_cert_manager                   = true
  enable_metrics_server = true
  cert_manager_route53_hosted_zone_arns = [data.aws_route53_zone.hosted_zone.arn]
  external_dns_route53_zone_arns        = [data.aws_route53_zone.hosted_zone.arn]
  external_dns = {
    values = ["${file("values/external-dns.yaml")}"]
  }

  metrics_server = {
    values = ["${file("values/metrics-server.yaml")}"]
  }

  tags = local.tags

  depends_on = [module.eks, data.aws_route53_zone.hosted_zone]
}