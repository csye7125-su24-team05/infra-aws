data "aws_route53_zone" "selected" {
  name         = var.route_record.zone
}

data "kubernetes_service" "istio_ingressgateway" {
  provider = kubernetes.k8s
  metadata {
    name      = "istio-ingressgateway"
    namespace = "istio-system"
  }
}


resource "aws_route53_record" "grafana" {
  zone_id = data.aws_route53_zone.selected.id # Replace with your Route 53 hosted zone ID
  name    = var.route_record.name
  type    = var.route_record.type
  ttl     = var.route_record.ttl

  records = [data.kubernetes_service.istio_ingressgateway.status[0].load_balancer.0.ingress.0.hostname]
}