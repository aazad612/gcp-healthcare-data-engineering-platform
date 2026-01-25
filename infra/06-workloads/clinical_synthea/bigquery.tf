# --- 1. BRONZE (Raw Ingestion) ---
resource "google_bigquery_dataset" "bronze" {
  for_each = var.environments

  dataset_id    = "synthea_bronze_${each.key}"
  # FIX: Use Map Lookup
  project       = local.env_project_ids[each.key]
  friendly_name = "Synthea Bronze (${each.key})"
  location      = var.data_location
  
  labels = {
    env   = each.key
    layer = "bronze"
    pii   = "true"
  }
}

# --- 2. SILVER (Cleaned/Enriched) ---
resource "google_bigquery_dataset" "silver" {
  for_each = var.environments

  dataset_id    = "synthea_silver_${each.key}"
  project       = local.env_project_ids[each.key]
  friendly_name = "Synthea Silver (${each.key})"
  location      = var.data_location

  labels = {
    env   = each.key
    layer = "silver"
  }
}

# --- 3. GOLD (Aggregated/Modeled) ---
resource "google_bigquery_dataset" "gold" {
  for_each = var.environments

  dataset_id    = "synthea_gold_${each.key}"
  project       = local.env_project_ids[each.key]
  friendly_name = "Synthea Gold (${each.key})"
  location      = var.data_location

  labels = {
    env   = each.key
    layer = "gold"
  }
}

# --- 4. INTERFACE (Consumption/Views) ---
resource "google_bigquery_dataset" "interface" {
  for_each = var.environments

  dataset_id    = "synthea_consumption_${each.key}"
  project       = local.env_project_ids[each.key]
  friendly_name = "Synthea Published (${each.key})"
  location      = var.data_location
  description   = "Public interface. Contains Authorized Views only."

  labels = {
    env   = each.key
    layer = "interface"
  }
}


# Grant the Default SA "Data Editor" on all datasets
resource "google_bigquery_dataset_access" "sa_editor_bronze" {
  for_each = var.environments

  dataset_id    = google_bigquery_dataset.bronze[each.key].dataset_id
  project       = local.env_project_ids[each.key]
  role          = "roles/bigquery.dataEditor"
  
  # FIX: Use the Service Account Map
  user_by_email = local.env_service_accounts[each.key]
}

resource "google_bigquery_dataset_access" "sa_editor_silver" {
  for_each = var.environments

  dataset_id    = google_bigquery_dataset.silver[each.key].dataset_id
  project       = local.env_project_ids[each.key]
  role          = "roles/bigquery.dataEditor"
  user_by_email = local.env_service_accounts[each.key]
}

resource "google_bigquery_dataset_access" "sa_editor_gold" {
  for_each = var.environments

  dataset_id    = google_bigquery_dataset.gold[each.key].dataset_id
  project       = local.env_project_ids[each.key]
  role          = "roles/bigquery.dataEditor"
  user_by_email = local.env_service_accounts[each.key]
}

resource "google_bigquery_dataset_access" "sa_owner_interface" {
  for_each = var.environments

  dataset_id    = google_bigquery_dataset.interface[each.key].dataset_id
  project       = local.env_project_ids[each.key]
  role          = "roles/bigquery.dataOwner"
  user_by_email = local.env_service_accounts[each.key]
}






