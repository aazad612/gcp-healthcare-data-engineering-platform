##############################################
# CONFIG BUCKETS (Shared Projects)
##############################################

resource "google_storage_bucket" "configs" {
  for_each = local.shared_projects

  name     = "bkt-clin-syn-configs-${each.key}"
  project  = local.project_ids[each.value]
  location = "US"

  uniform_bucket_level_access = true
  force_destroy               = true

  lifecycle {
    prevent_destroy = true
  }
}

output "config_buckets" {
  value = {
    for env, b in google_storage_bucket.configs :
    env => b.name
  }
}

##############################################
# IAM — allow project-service-account to read/write config
##############################################

resource "google_storage_bucket_iam_member" "contract_admin" {
  for_each = local.shared_projects

  bucket = google_storage_bucket.configs[each.key].name
  role   = "roles/storage.objectAdmin"

  member = "serviceAccount:project-service-account@${local.project_ids[each.value]}.iam.gserviceaccount.com"
}

