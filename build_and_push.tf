resource "null_resource" "build_and_push" {
  provisioner "local-exec" {
    command = <<-EOT
      docker build -t europe-north1-docker.pkg.dev/${var.project_id}/hello-app/hello-app:latest .
      docker push europe-north1-docker.pkg.dev/${var.project_id}/hello-app/hello-app:latest
    EOT
  }

  depends_on = [google_artifact_registry_repository.repo]
}
