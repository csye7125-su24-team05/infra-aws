data "aws_route53_zone" "hosted_zone" {
  provider = aws.profile
  name     = "grafana.nexflare.me"
}