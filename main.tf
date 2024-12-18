provider "google" {
  project     = "hello-terraform-333"
  region      = "europe-north1"
  credentials = file("terraform-key.json")
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "vpcaccess.googleapis.com"
  ])

  project = "hello-terraform-333"
  service = each.key
  disable_dependent_services = true
  disable_on_destroy = false
}

# VPC Network (existing)
resource "google_compute_network" "vpc" {
  name                    = "hello-vpc"
  auto_create_subnetworks = false
}

# Subnet (existing)
resource "google_compute_subnetwork" "subnet" {
  name          = "hello-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc.id
  region        = "europe-north1"
}

# Artifact Registry Repository for containers
resource "google_artifact_registry_repository" "repo" {
  location      = "europe-north1"
  repository_id = "hello-app"
  description   = "Docker repository for hello app"
  format        = "DOCKER"
  depends_on    = [google_project_service.required_apis]
}

# Cloud Run service
resource "google_cloud_run_service" "hello" {
  name     = "hello-service"
  location = "europe-north1"

  template {
    spec {
      containers {
        image = "${google_artifact_registry_repository.repo.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}/hello-app:latest"
        ports {
          container_port = 8080
        }
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "2"
        "autoscaling.knative.dev/minScale"      = "1"
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.id
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.required_apis]
}

# VPC Access Connector for private networking
resource "google_vpc_access_connector" "connector" {
  name          = "hello-vpc-connector"
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.vpc.name
  region        = "europe-north1"
  min_instances = 2
  max_instances = 3
}

# IAM - Allow public access to Cloud Run service
resource "google_cloud_run_service_iam_member" "public" {
  location = google_cloud_run_service.hello.location
  service  = google_cloud_run_service.hello.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Outputs
output "service_url" {
  value = google_cloud_run_service.hello.status[0].url
}

output "service_url_hello" {
  value = "${google_cloud_run_service.hello.status[0].url}/hello"
}

output "service_url_hello_name" {
  value = "${google_cloud_run_service.hello.status[0].url}/hello?name=my%20beautiful%20friend"
}

output "service_url_health" {
  value = "${google_cloud_run_service.hello.status[0].url}/health"
}
