data "aws_route53_zone" "grafana" {
  provider = aws.profile
  name     = "grafana.nexflare.me"
}

data "aws_route53_zone" "cve" {
  provider = aws.profile
  name     = "cve.nexflare.me"
}