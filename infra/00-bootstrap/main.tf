# 00-bootstrap/main.tf

provider "google" {
  region = var.region
}

# 1. Random ID for unique project/bucket names
resource "random_id" "suffix" {
  byte_length = 4
}

# 2. The "Seed" Project (Where Terraform lives)
resource "google_project" "seed_project" {
  name            = "syn-admin-bs"
  project_id      = "prj-syn-admin-bs-${random_id.suffix.hex}"
  billing_account = var.billing_account
  org_id          = var.org_id
}

# 3. Enable APIs required for Terraform to work
resource "google_project_service" "apis" {
  project = google_project.seed_project.project_id
  service = "cloudresourcemanager.googleapis.com"
  
  # Enable these to allow Terraform to manage other resources
  disable_on_destroy = false
}

resource "google_project_service" "iam" {
  project = google_project.seed_project.project_id
  service = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "storage" {
  project = google_project.seed_project.project_id
  service = "storage.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "admin" {
  project = google_project.seed_project.project_id
  service = "admin.googleapis.com" # Required for your Identity management
  disable_on_destroy = false
}

# 4. The GCS Bucket for Remote State (The "Brain")
resource "google_storage_bucket" "tf_state" {
  name          = "bkt-tfstate-${random_id.suffix.hex}"
  project       = google_project.seed_project.project_id
  location      = "US"
  force_destroy = false

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true
}

# 5. The "Super" Service Account
# This is the robot that will run Terraform for layers 01-06
resource "google_service_account" "terraform_sa" {
  account_id   = "sa-terraform-runner"
  display_name = "Terraform Orchestrator"
  project      = google_project.seed_project.project_id
}

# Grant this SA permission to manage the Organization
# (Be careful: This grants it power over everything)
resource "google_organization_iam_member" "org_admin" {
  org_id = var.org_id
  role   = "roles/resourcemanager.organizationAdmin"
  member = "serviceAccount:${google_service_account.terraform_sa.email}"
}

resource "google_organization_iam_member" "billing_user" {
  org_id = var.org_id
  role   = "roles/billing.user"
  member = "serviceAccount:${google_service_account.terraform_sa.email}"
}

