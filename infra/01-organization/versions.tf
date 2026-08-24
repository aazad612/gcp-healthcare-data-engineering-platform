terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "bkt-tfstate-b2796051"       # prj-syn-admin-bs-b2796051
    prefix = "syn-org"
  }
}

provider "google" {
  region                      = "us-central1"
  user_project_override       = true
  billing_project             = "johneysadminproject" # Optional: Helps with quota attribution
  impersonate_service_account = var.impersonate_service_account
}