resource "google_project" "res_host" {
  name            = var.host_projects["research"].project_id
  project_id      = var.host_projects["research"].project_id
  folder_id       = local.folder_ids[var.host_projects["research"].folder_key]
  billing_account = var.billing_account_id
}

resource "google_project_service" "res_apis" {
  project = google_project.res_host.project_id
  service = "compute.googleapis.com"
}
resource "google_project_service" "res_iam" {
  project = google_project.res_host.project_id
  service = "iam.googleapis.com"
}


resource "google_compute_shared_vpc_host_project" "res_host" {
  project    = google_project.res_host.project_id
  depends_on = [google_project_service.res_apis]
}

resource "google_compute_network" "res_vpc" {
  name                    = var.host_projects["research"].vpc_name
  project                 = google_project.res_host.project_id
  auto_create_subnetworks = false
  depends_on = [
    google_project_service.res_apis
  ]
}

resource "google_compute_subnetwork" "res_int" {
  name          = var.subnets["res_int"].name
  ip_cidr_range = var.subnets["res_int"].cidr
  region        = var.subnets["res_int"].region
  project       = google_project.res_host.project_id
  network       = google_compute_network.res_vpc.id
}