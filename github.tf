resource "null_resource" "download_chart" {
  provisioner "local-exec" {
    command = <<EOT
      curl -L -H "Accept: application/octet-stream" -H "Authorization: token ${var.autoscaler.token}" -H "X-GitHub-Api-Version: 2022-11-28" -o ${var.autoscaler.chart} ${var.autoscaler.chart_url}
    EOT
  }
}