resource "helm_release" "llm" {
  provider   = helm.eks-helm
  name       = "ollama"
  repository = "https://otwld.github.io/ollama-helm/"
  chart      = "ollama"
  values     = ["${file("values/llm.yaml")}"]
  namespace  = var.namespaces["llm"].name

  depends_on = [kubernetes_namespace.namespace, helm_release.istiod]
}