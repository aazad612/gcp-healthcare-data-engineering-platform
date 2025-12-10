# --- Ops Metadata Dataset (Multi-Env) ---
resource "google_bigquery_dataset" "ops_metadata" {
  for_each = var.target_projects

  dataset_id    = "ops_metadata"
  # Look up the actual Project ID using the logical key (e.g. shared_orch_pd)
  project       = local.project_ids[each.value]
  
  friendly_name = "Platform Metadata & Standards (${upper(each.key)})"
  description   = "Stores Golden Rules, Audit Logs, and Pipeline Configs."
  location      = var.data_location
  
  delete_contents_on_destroy = false 

  # --- Access Control ---
  
  # 1. The Pipeline Robot (sa-orchestrator)
  # Needs OWNER rights to create/drop tables via Cloud Build/Airflow
  access {
    role          = "OWNER"
    user_by_email = local.pipeline_sas[each.value]
  }

  # 2. Data Engineers (Humans) - Read Only
  access {
    role           = "READER"
    group_by_email = "data-engineering-admins@aazads.us"
  }
  
  # 3. Governance Stewards - Read Only
  access {
    role           = "READER"
    group_by_email = "data-governance-stewards@aazads.us"
  }
}