# Grant the Default SA "Data Editor" on all datasets
# This allows it to run dbt models that write to these datasets
resource "google_bigquery_dataset_access" "sa_editor_bronze" {
  for_each = var.environments

  dataset_id    = google_bigquery_dataset.bronze[each.key].dataset_id
  project       = local.project_id
  role          = "roles/bigquery.dataEditor"
  user_by_email = local.default_sa
}

resource "google_bigquery_dataset_access" "sa_editor_silver" {
  for_each = var.environments

  dataset_id    = google_bigquery_dataset.silver[each.key].dataset_id
  project       = local.project_id
  role          = "roles/bigquery.dataEditor"
  user_by_email = local.default_sa
}

resource "google_bigquery_dataset_access" "sa_editor_gold" {
  for_each = var.environments

  dataset_id    = google_bigquery_dataset.gold[each.key].dataset_id
  project       = local.project_id
  role          = "roles/bigquery.dataEditor"
  user_by_email = local.default_sa
}

# Grant "Data Owner" on Interface (required to create Authorized Views)
resource "google_bigquery_dataset_access" "sa_owner_interface" {
  for_each = var.environments

  dataset_id    = google_bigquery_dataset.interface[each.key].dataset_id
  project       = local.project_id
  role          = "roles/bigquery.dataOwner"
  user_by_email = local.default_sa
}