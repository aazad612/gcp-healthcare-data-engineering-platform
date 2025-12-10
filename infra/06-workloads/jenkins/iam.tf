# A. Define the Service Account in the Hub Project (where Jenkins runs)
resource "google_service_account" "jenkins_deployer_sa" {
  account_id   = "jenkins-deployer-id"
  display_name = "Jenkins Deployer Service Account"
  project      = local.hub_project
}

resource "google_project_iam_member" "jenkins_sa_editor_role_on_hub" {
  for_each = toset(var.jenkins_hub_roles)
  project = local.hub_project 
  role    = each.key
  member  = "serviceAccount:${google_service_account.jenkins_deployer_sa.email}"
}

variable "jenkins_hub_roles" {
  description = "List of IAM roles required for the Jenkins Deployer SA in the Hub Project."
  type        = list(string)
  default = [
    "roles/editor",            # For broad resource management
    "roles/bigquery.jobUser",   # To solve the bigquery.jobs.create error
    "roles/bigquery.dataEditor"# Add any other essential roles here (e.g., storage viewer, KMS roles)
  ]
}


data "terraform_remote_state" "domains" {
  backend = "gcs"

  config = {
    bucket = "johneys-tf-states"
    prefix = "healthcare-landing-zone/05-domains"
  }
}

variable "target_project_key" {
  description = "Logical key from Layer 05 (e.g., clin_syn_np)."
  type        = string
  default     = "clin_syn_np"
}

# locals {
#   project_id = data.terraform_remote_state.domains.outputs.project_ids[var.target_project_key]
#   default_sa = data.terraform_remote_state.domains.outputs.service_accounts[var.target_project_key]
# }


# Grant the Jenkins Deployer SA the right to impersonate the
# Default Compute SA in all Service Projects.

# resource "google_service_account_iam_member" "jenkins_sa_impersonator_grant" {
#   # Use the project_ids map to iterate over the service projects
#   # Example: "dev-project" = "dev-project-id"
#   for_each           = local.project_id
#   service_account_id = local.default_sa
#   role               = "roles/iam.serviceAccountTokenCreator"
#   member             = "serviceAccount:${google_service_account.jenkins_deployer_sa.email}"

#   depends_on = [
#     google_service_account.jenkins_deployer_sa
#   ]
# }

# Corrected resource block in iam.tf

resource "google_service_account_iam_member" "jenkins_sa_impersonator_grant" {
  for_each           = data.terraform_remote_state.domains.outputs.project_ids
  service_account_id = "projects/${each.value}/serviceAccounts/${data.terraform_remote_state.domains.outputs.service_accounts[each.key]}"
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.jenkins_deployer_sa.email}"
}