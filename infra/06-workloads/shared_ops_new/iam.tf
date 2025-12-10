# 1. Look up Project Details
# We need this to get the 'project_number' to construct the default Cloud Build email
data "google_project" "target" {
  for_each   = var.target_projects
  project_id = local.project_ids[each.value]
}

locals {
  # Construct the Default Cloud Build Service Account Email
  # Format: [PROJECT_NUMBER]@cloudbuild.gserviceaccount.com
  cloudbuild_sas = {
    for env, proj_key in var.target_projects :
    env => "${data.google_project.target[env].number}@cloudbuild.gserviceaccount.com"
  }
}

resource "google_bigquery_dataset_iam_member" "pipeline_owner" {
  for_each = var.target_projects

  dataset_id = google_bigquery_dataset.ops_metadata[each.key].dataset_id
  project    = local.project_ids[each.value]
  role       = "roles/bigquery.dataOwner"
  member     = "serviceAccount:${local.pipeline_sas[each.value]}"
}


# 2. Grant "BigQuery Job User" (Project Level)
# This allows the Cloud Build robot to execute SQL queries in the project.
resource "google_project_iam_member" "cb_job_user" {
  for_each = var.target_projects

  project = local.project_ids[each.value]
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${local.cloudbuild_sas[each.key]}"

  depends_on = [
    google_bigquery_dataset.ops_metadata
  ]
}

# 3. Grant "BigQuery Data Viewer" (Dataset Level)
# This allows the Cloud Build robot to READ the 'standards_definition' table during validation.
resource "google_bigquery_dataset_access" "cb_data_viewer" {
  for_each = var.target_projects

  dataset_id    = google_bigquery_dataset.ops_metadata[each.key].dataset_id
  project       = local.project_ids[each.value]
  role          = "roles/bigquery.dataViewer"
  user_by_email = local.cloudbuild_sas[each.key]
  depends_on = [
    google_bigquery_dataset.ops_metadata
  ]
}

# --- ADD THIS RESOURCE ---
# Grant Data Editor/Owner privileges to the Cloud Build SA for the Ops Metadata dataset.

resource "google_bigquery_dataset_access" "cb_data_editor" {
  # We use 'for_each' to ensure this is applied to both NP and PD Ops datasets
  for_each = var.target_projects

  dataset_id = google_bigquery_dataset.ops_metadata[each.key].dataset_id
  project    = local.project_ids[each.value]

  # The Cloud Build robot needs OWNER/DATAEDITOR to CREATE/DELETE/TRUNCATE tables.
  role = "roles/bigquery.dataEditor"

  # The Cloud Build Service Account email is constructed using the project number
  user_by_email = local.cloudbuild_sas[each.key]
  depends_on = [
    google_bigquery_dataset.ops_metadata
  ]
}

