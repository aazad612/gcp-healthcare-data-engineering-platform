locals {
  # Auto-detect NP & PD service projects based on project_id suffix
  np_service_projects = {
    for k, v in var.service_projects :
    k => v if can(regex(".*-np$", v.project_id))
  }

  pd_service_projects = {
    for k, v in var.service_projects :
    k => v if can(regex(".*-pd$", v.project_id))
  }

  # Shared project identifiers
  shared_np_project = var.service_projects["shared_np"].project_id
  shared_pd_project = var.service_projects["shared_pd"].project_id
}

##########################################
#  NP → Shared NP
##########################################

resource "google_bigquery_dataset_iam_member" "np_shared_dataset_read" {
  for_each = local.np_service_projects

  project    = local.shared_np_project
  dataset_id = "ops_metadata"
  role       = "roles/bigquery.dataViewer"

  member = "serviceAccount:project-service-account@${each.value.project_id}.iam.gserviceaccount.com"
}

resource "google_bigquery_dataset_iam_member" "np_shared_metadata_read" {
  for_each = local.np_service_projects

  project    = local.shared_np_project
  dataset_id = "ops_metadata"
  role       = "roles/bigquery.metadataViewer"

  member = "serviceAccount:project-service-account@${each.value.project_id}.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "np_shared_job_user" {
  for_each = local.np_service_projects

  project = local.shared_np_project
  role    = "roles/bigquery.user"

  member = "serviceAccount:project-service-account@${each.value.project_id}.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "np_shared_data_edior" {
  for_each = local.np_service_projects

  project = local.shared_np_project
  role    = "roles/bigquery.dataEditor"

  member = "serviceAccount:project-service-account@${each.value.project_id}.iam.gserviceaccount.com"
}

# Add a new resource to specifically grant Data Editor at the Dataset Level
resource "google_bigquery_dataset_iam_member" "np_shared_data_editor_dataset" {
  # This targets only the clin_syn_np service project, which is the failing function
  for_each = {
    "clin_syn_np" = local.np_service_projects["clin_syn_np"] 
    # Add other NP projects here if they also write audit records
  } 

  project    = local.shared_np_project
  dataset_id = "ops_metadata"
  role       = "roles/bigquery.dataEditor"

  member = "serviceAccount:project-service-account@${each.value.project_id}.iam.gserviceaccount.com"
}

resource "google_storage_bucket_iam_member" "np_shared_config_bucket_read" {
  # Re-use the existing local list of NP projects
  for_each = local.np_service_projects

  # The specific bucket in the Shared Project
  bucket = "bkt-clin-syn-configs-np"

  # Grant Read access
  role   = "roles/storage.objectViewer"

  # Construct the email exactly like you did for BigQuery above
  member = "serviceAccount:project-service-account@${each.value.project_id}.iam.gserviceaccount.com"
}

##########################################
#  PD → Shared PD
##########################################

resource "google_bigquery_dataset_iam_member" "pd_shared_dataset_read" {
  for_each = local.pd_service_projects

  project    = local.shared_pd_project
  dataset_id = "ops_metadata"
  role       = "roles/bigquery.dataViewer"

  member = "serviceAccount:project-service-account@${each.value.project_id}.iam.gserviceaccount.com"
}

resource "google_bigquery_dataset_iam_member" "pd_shared_metadata_read" {
  for_each = local.pd_service_projects

  project    = local.shared_pd_project
  dataset_id = "ops_metadata"
  role       = "roles/bigquery.metadataViewer"

  member = "serviceAccount:project-service-account@${each.value.project_id}.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "pd_shared_job_user" {
  for_each = local.pd_service_projects

  project = local.shared_pd_project
  role    = "roles/bigquery.user"

  member = "serviceAccount:project-service-account@${each.value.project_id}.iam.gserviceaccount.com"
}


resource "google_project_iam_member" "pd_shared_data_edior" {
  for_each = local.pd_service_projects

  project = local.shared_pd_project
  role    = "roles/bigquery.dataEditor"

  member = "serviceAccount:project-service-account@${each.value.project_id}.iam.gserviceaccount.com"
}
