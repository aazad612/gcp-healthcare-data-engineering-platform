terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "johneys-tf-states"
    prefix = "healthcare-landing-zone/workloads/00_shared_ops"
  }
}

provider "google" {
  region                      = "us-central1"
  user_project_override       = true
  billing_project             = "johneysadminproject"
  impersonate_service_account = var.impersonate_service_account
}