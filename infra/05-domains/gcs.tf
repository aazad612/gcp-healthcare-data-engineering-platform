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


