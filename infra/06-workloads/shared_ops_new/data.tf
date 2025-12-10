data "terraform_remote_state" "domains" {
  backend = "gcs"
  config = {
    bucket = "johneys-tf-states"
    prefix = "healthcare-landing-zone/05-domains"
  }
}

locals {

  # project_ids loaded from remote state
  project_ids     = data.terraform_remote_state.domains.outputs.project_ids
  project_numbers = data.terraform_remote_state.domains.outputs.project_numbers
  pipeline_sas    = data.terraform_remote_state.domains.outputs.service_accounts

  # Shared projects stay the same (Dataflow runs here)
  shared_projects = {
    np = "shared_np"
    pd = "shared_pd"
  }

  # Domain projects = everything except shared_* keys
  domain_projects = {
    for key, _ in local.project_ids :
    key => local.project_ids[key]
    if !contains(["shared_np", "shared_pd"], key)
  }

  # Identify env (pd or dev)
  domain_to_env = {
    for k in keys(local.domain_projects) :
    k => (
      can(regex("(_pd|_prod)$", k)) ? "pd" :
      can(regex("(_np|_dev|_qa|_uat)$", k)) ? "np" :
      "np"
    )
  }

  ###########################################
  # EXTRACT THE SUFFIX (clin_syn_dev, clin_hosp_pd, etc.)
  ###########################################
  domain_suffix = {
    for k in keys(local.domain_projects) :
    k => replace(k, ".*_", "")
  }

  ###########################################
  # FINAL RAW BUCKET NAMES (YOU APPROVED)
  ###########################################
  data_lake_buckets = {
    for domain_key, project_id in local.domain_projects :
    domain_key => (
      local.domain_to_env[domain_key] == "np" ?
      "bkt-clin-syn-lake-dev-${project_id}" :
      "bkt-clin-syn-lake-pd-${project_id}"
    )
  }
}
