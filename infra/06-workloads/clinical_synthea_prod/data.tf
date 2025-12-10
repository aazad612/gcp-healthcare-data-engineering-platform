data "terraform_remote_state" "domains" {
  backend = "gcs"
  config = {
    bucket = "johneys-tf-states"
    prefix = "healthcare-landing-zone/05-domains"
  }
}

locals {
  # Look up the real Project ID using the logical key (e.g., clin_syn_np)
  project_id = data.terraform_remote_state.domains.outputs.project_ids[var.target_project_key]
  
  # Look up the Default Service Account email (since you kept the default)
  # We need this to grant it permissions on buckets/datasets
  default_sa = data.terraform_remote_state.domains.outputs.service_accounts[var.target_project_key]
}