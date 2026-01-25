resource "google_storage_bucket" "data_lake" {
  for_each = var.environments

  # FIX: Ensure bucket includes the correct project suffix
  name          = "bkt-clin-syn-lake-${each.key}-${local.env_project_ids[each.key]}"
  project       = local.env_project_ids[each.key]
  location      = var.data_location
  force_destroy = false
  
  uniform_bucket_level_access = true
}

