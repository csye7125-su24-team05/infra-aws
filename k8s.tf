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
    labels = {
      istio-injection = try(each.value.istio_injection, "disabled")
    }
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

resource "kubernetes_limit_range" "limit_range" {
  provider = kubernetes.k8s
  for_each = var.namespaces
  metadata {
    name      = "limit-range"
    namespace = each.value.name
  }
  spec {
    limit {
      type = "Container"
      default = {
        memory = var.limit_range.default_limit.memory
        cpu    = var.limit_range.default_limit.cpu
      }
      default_request = {
        memory = var.limit_range.default_request.memory
        cpu    = var.limit_range.default_request.cpu
      }
    }
  }

  depends_on = [module.eks, kubernetes_namespace.namespace]

}

resource "kubernetes_network_policy" "network_policy" {
  provider = kubernetes.k8s
  for_each = {
    for ns, ns_data in var.namespaces : ns => ns_data
    if ns_data.istio_injection == "enabled"
  }
  metadata {
    name      = "network-policy"
    namespace = each.value.name
  }
  spec {
    pod_selector {
      match_expressions {
        key      = "sidecar.istio.io/inject"
        operator = "NotIn"
        values   = ["false"]
      }
    }
    ingress {
      from {
        namespace_selector {}
      }
      from {
        pod_selector {
          match_expressions {
            key      = "app.kubernetes.io/name"
            operator = "In"
            values   = ["prometheus", "istiod"]
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = "15090"
      }
      ports {
        protocol = "TCP"
        port     = "15020"
      }

      ports {
        protocol = "TCP"
        port     = "8080"
      }
    }

    egress {}
    policy_types = ["Ingress", "Egress"]
  }

  depends_on = [module.eks, kubernetes_namespace.namespace]
}
