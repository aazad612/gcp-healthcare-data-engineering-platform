resource "google_project" "hub_host" {
  name            = var.host_projects["hub"].project_id
  project_id      = var.host_projects["hub"].project_id
  folder_id       = local.folder_ids[var.host_projects["hub"].folder_key]
  billing_account = var.billing_account_id
}

resource "google_project_service" "hub_apis" {
  project = google_project.hub_host.project_id
  service = "compute.googleapis.com"
}

resource "google_project_service" "hub_iap" {
  project = google_project.hub_host.project_id
  service = "iap.googleapis.com"
}

resource "google_project_service" "hub_bigquery" {
  project = google_project.hub_host.project_id
  service = "bigquery.googleapis.com"
}

resource "google_project_service" "hub_iam" {
  project = google_project.hub_host.project_id
  service = "iam.googleapis.com"
}

resource "google_compute_shared_vpc_host_project" "hub_host" {
  project    = google_project.hub_host.project_id
  depends_on = [google_project_service.hub_apis]
}

resource "google_compute_network" "hub_vpc" {
  name                    = var.host_projects["hub"].vpc_name # <--- Parameterized
  project                 = google_project.hub_host.project_id
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "hub_subnet" {
  name          = var.subnets["hub_main"].name
  ip_cidr_range = var.subnets["hub_main"].cidr
  region        = var.subnets["hub_main"].region
  project       = google_project.hub_host.project_id
  network       = google_compute_network.hub_vpc.id
}