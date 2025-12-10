resource "google_project" "clin_host" {
  name            = var.host_projects["clinical"].project_id
  project_id      = var.host_projects["clinical"].project_id
  folder_id       = local.folder_ids[var.host_projects["clinical"].folder_key]
  billing_account = var.billing_account_id
}

resource "google_project_service" "clin_apis" {
  project = google_project.clin_host.project_id
  service = "compute.googleapis.com"
}

resource "google_project_service" "clin_iam" {
  project = google_project.clin_host.project_id
  service = "iam.googleapis.com"
}

resource "google_compute_shared_vpc_host_project" "clin_host" {
  project    = google_project.clin_host.project_id
  depends_on = [google_project_service.clin_apis]
}

resource "google_compute_network" "clin_vpc" {
  name                    = var.host_projects["clinical"].vpc_name
  project                 = google_project.clin_host.project_id
  auto_create_subnetworks = false
  depends_on = [
    google_project_service.clin_apis
  ]
}

resource "google_compute_subnetwork" "clin_int" {
  name          = var.subnets["clin_int"].name
  ip_cidr_range = var.subnets["clin_int"].cidr
  region        = var.subnets["clin_int"].region
  project       = google_project.clin_host.project_id
  network       = google_compute_network.clin_vpc.id
}

resource "google_compute_subnetwork" "clin_ext" {
  name          = var.subnets["clin_ext"].name
  ip_cidr_range = var.subnets["clin_ext"].cidr
  region        = var.subnets["clin_ext"].region
  project       = google_project.clin_host.project_id
  network       = google_compute_network.clin_vpc.id
}