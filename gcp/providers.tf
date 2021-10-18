provider "google" {
  // run gcloud auth application-default login
  project = var.project
  region  = var.region
  zone =  "${var.region}-a"
}