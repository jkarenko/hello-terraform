terraform {
  backend "gcs" {
    bucket = "hello-terraform-333-terraform-state"
    prefix = "terraform/state"
    credentials = "terraform-key.json"
  }
}
