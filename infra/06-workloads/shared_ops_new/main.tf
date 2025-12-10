# --- Ops Metadata Dataset (Multi-Env) ---
resource "google_bigquery_dataset" "ops_metadata" {
  for_each = var.target_projects

  dataset_id = "ops_metadata"
  # Look up the actual Project ID using the logical key (e.g. shared_orch_pd)
  project = local.project_ids[each.value]

  friendly_name = "Platform Metadata & Standards (${upper(each.key)})"
  description   = "Stores Golden Rules, Audit Logs, and Pipeline Configs."
  location      = var.data_location

  delete_contents_on_destroy = false

}