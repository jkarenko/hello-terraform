provider "google" {
  project     = "hello-terraform-333"
  region      = "europe-north1"
  credentials = file("terraform-key.json")
}

# Create VPC network
resource "google_compute_network" "vpc" {
  name                    = "hello-vpc"
  auto_create_subnetworks = false
}

# Create subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "hello-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc.id
  region        = "europe-north1"
}
