resource "null_resource" "download_chart" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOT
      curl -L -H "Accept: application/octet-stream" -H "Authorization: token ${var.autoscaler.token}" -H "X-GitHub-Api-Version: 2022-11-28" -o ${var.autoscaler.chart} ${var.autoscaler.chart_url}
    EOT
  }
}

resource "null_resource" "cloudwatch_download_chart" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOT
      curl -L -H "Accept: application/octet-stream" -H "Authorization: token ${var.cloudwatch.token}" -H "X-GitHub-Api-Version: 2022-11-28" -o ${var.cloudwatch.chart} ${var.cloudwatch.chart_url}
    EOT
  }
}

resource "null_resource" "prometheus_download_chart" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOT
      curl -L -H "Accept: application/octet-stream" -H "Authorization: token ${var.prometheus.token}" -H "X-GitHub-Api-Version: 2022-11-28" -o ${var.prometheus.chart} ${var.prometheus.chart_url}
    EOT
  }
}

resource "null_resource" "cert_manager_download_chart" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOT
      curl -L -H "Accept: application/octet-stream" -H "Authorization: token ${var.certificate.token}" -H "X-GitHub-Api-Version: 2022-11-28" -o ${var.certificate.chart} ${var.certificate.chart_url}
    EOT
  }
}