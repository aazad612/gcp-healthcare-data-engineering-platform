data "terraform_remote_state" "domains" {
  backend = "gcs"
  config = {
    bucket = "johneys-tf-states"
    prefix = "healthcare-landing-zone/05-domains"
  }
}

locals {
  # Map of all Project IDs
  project_ids = data.terraform_remote_state.domains.outputs.project_ids
  
  # Map of all Service Accounts
  pipeline_sas = data.terraform_remote_state.domains.outputs.service_accounts
}