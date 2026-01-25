data "terraform_remote_state" "domains" {
  backend = "gcs"
  config = {
    bucket = "johneys-tf-states"
    prefix = "healthcare-landing-zone/05-domains"
  }
}

locals {
  # 1. Map Environment -> Project ID
  # Example: "dev" -> "prj-clin-syn-np", "test" -> "prj-clin-syn-uat"
  env_project_ids = {
    for env, key in var.env_project_keys : 
    env => data.terraform_remote_state.domains.outputs.project_ids[key]
  }

  # 2. Map Environment -> Default Compute Service Account
  # Used for BigQuery/Dataset permissions
  env_service_accounts = {
    for env, key in var.env_project_keys : 
    env => data.terraform_remote_state.domains.outputs.service_accounts[key]
  }

  # 3. Map Environment -> GCS Service Account
  # Used for Pub/Sub publishing permissions. 
  env_gcs_service_accounts = {
    for env, key in var.env_project_keys : 
    env => data.terraform_remote_state.domains.outputs.gcs_service_accounts[key]
  }
}



data "terraform_remote_state" "shared_ops" {
  backend = "gcs"
  config = {
    bucket = "johneys-tf-states"
    prefix = "healthcare-landing-zone/workloads/00_shared_ops"
  }
}

locals {
  df_runners = data.terraform_remote_state.shared_ops.outputs.df_runner_service_accounts
}

