resource "google_project" "ent_host" {
  name            = var.host_projects["enterprise"].project_id
  project_id      = var.host_projects["enterprise"].project_id
  folder_id       = local.folder_ids[var.host_projects["enterprise"].folder_key]
  billing_account = var.billing_account_id
}

resource "google_project_service" "ent_apis" {
  project = google_project.ent_host.project_id
  service = "compute.googleapis.com"
}

resource "google_compute_shared_vpc_host_project" "ent_host" {
  project    = google_project.ent_host.project_id
  depends_on = [google_project_service.ent_apis]
}

resource "google_project_service" "ent_iam" {
  project = google_project.ent_host.project_id
  service = "iam.googleapis.com"
}



resource "google_compute_network" "ent_vpc" {
  name                    = var.host_projects["enterprise"].vpc_name # <--- Parameterized
  project                 = google_project.ent_host.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "ent_int" {
  name          = var.subnets["ent_int"].name
  ip_cidr_range = var.subnets["ent_int"].cidr
  region        = var.subnets["ent_int"].region
  project       = google_project.ent_host.project_id
  network       = google_compute_network.ent_vpc.id
}