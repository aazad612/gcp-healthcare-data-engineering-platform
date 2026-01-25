# 1. Get Project Details for the Non-Prod Orchestrator
# We need this to get the 'project_number' for the Cloud Build SA
# data "google_project" "orch_np" {
#   project_id = module.service_projects["shared_orch_np"].project_id
# }

# locals {
#   # Construct the Cloud Build Service Account Email
#   # Format: [PROJECT_NUMBER]@cloudbuild.gserviceaccount.com
#   cloudbuild_sa_np = "${data.google_project.orch_np.number}@cloudbuild.gserviceaccount.com"
# }

# 2. Grant "BigQuery Admin" to the Orchestrator on the Clinical Project
# This allows Cloud Build (in Shared) to create/update tables in Clinical
# resource "google_project_iam_member" "cb_deployer_clin_bq" {
#   project = module.service_projects["clin_syn_np"].project_id
#   role    = "roles/bigquery.admin"
#   member  = "serviceAccount:${local.cloudbuild_sa_np}"
# }

# # 3. Grant "BigQuery Job User" to the Orchestrator
# # This allows Cloud Build to run the actual DDL queries
# resource "google_project_iam_member" "cb_deployer_clin_job" {
#   project = module.service_projects["clin_syn_np"].project_id
#   role    = "roles/bigquery.jobUser"
#   member  = "serviceAccount:${local.cloudbuild_sa_np}"
# }


