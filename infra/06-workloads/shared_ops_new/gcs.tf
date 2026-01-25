###########################################
# DATAFLOW TEMP BUCKETS (Shared Projects)
###########################################

resource "google_storage_bucket" "df_temp" {
  for_each = local.shared_projects

  name     = "bkt-df-temp-${each.key}-${local.project_ids[each.value]}"
  project  = local.project_ids[each.value]
  location = "US"

  uniform_bucket_level_access = true
  force_destroy               = true
}

output "df_temp_buckets" {
  value = {
    for env, bucket in google_storage_bucket.df_temp :
    env => bucket.name
  }
}

###########################################
# DATAFLOW TEMP BUCKET IAM
###########################################

resource "google_storage_bucket_iam_member" "df_temp_access" {
  for_each = local.shared_projects

  bucket = google_storage_bucket.df_temp[each.key].name
  role   = "roles/storage.objectAdmin"

  member = "serviceAccount:${google_service_account.df_runner[each.key].email}"
}


# ###########################################
# # RAW BUCKET ACCESS — DOMAIN PROJECTS
# ###########################################

# # local.data_lake_buckets = dynamic bucket names based on suffix mapping.

# resource "google_storage_bucket_iam_member" "df_raw_admin" {
#   for_each = local.domain_projects

#   bucket = local.data_lake_buckets[each.key]
#   role   = "roles/storage.objectAdmin"
#   member = "serviceAccount:${google_service_account.df_runner[local.domain_to_env[each.key]].email}"
# }


# output "df_raw_bucket_access" {
#   value = {
#     for key, _ in local.domain_projects :
#     key => {
#       bucket = local.data_lake_buckets[key]
#       sa     = google_service_account.df_runner[local.domain_to_env[key]].email
#     }
#   }
# }
