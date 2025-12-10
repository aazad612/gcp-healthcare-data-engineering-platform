# --- 1. BRONZE (Raw Ingestion) ---
# Data flows here from GCS/PubSub. No schema enforcement.
resource "google_bigquery_dataset" "bronze" {
  for_each = var.environments

  dataset_id    = "synthea_bronze_${each.key}"
  project       = local.project_id
  friendly_name = "Synthea Bronze (${each.key})"
  location      = var.data_location
  
  labels = {
    env   = each.key
    layer = "bronze"
    pii   = "true" # Raw data often contains PII
  }
}

# --- 2. SILVER (Cleaned/Enriched) ---
# Deduplicated, typed, and roughly compliant data.
resource "google_bigquery_dataset" "silver" {
  for_each = var.environments

  dataset_id    = "synthea_silver_${each.key}"
  project       = local.project_id
  friendly_name = "Synthea Silver (${each.key})"
  location      = var.data_location

  labels = {
    env   = each.key
    layer = "silver"
  }
}

# --- 3. GOLD (Aggregated/Modeled) ---
# Dimensional models, Facts. The "Truth". 
# NO DIRECT USER ACCESS here usually.
resource "google_bigquery_dataset" "gold" {
  for_each = var.environments

  dataset_id    = "synthea_gold_${each.key}"
  project       = local.project_id
  friendly_name = "Synthea Gold (${each.key})"
  location      = var.data_location

  labels = {
    env   = each.key
    layer = "gold"
  }
}

# --- 4. INTERFACE (Consumption/Views) ---
# Authorized Views live here. Users connect Tableau/Looker here.
resource "google_bigquery_dataset" "interface" {
  for_each = var.environments

  dataset_id    = "synthea_consumption_${each.key}"
  project       = local.project_id
  friendly_name = "Synthea Published (${each.key})"
  location      = var.data_location
  description   = "Public interface. Contains Authorized Views only."

  labels = {
    env   = each.key
    layer = "interface"
  }
}

# --- 5. GCS Buckets (Data Lake) ---
# One bucket per layer/env is often overkill. 
# A common pattern is one bucket per env with folders.
resource "google_storage_bucket" "data_lake" {
  for_each = var.environments

  name          = "bkt-clin-syn-lake-${each.key}-${local.project_id}"
  project       = local.project_id
  location      = var.data_location
  force_destroy = false
  
  uniform_bucket_level_access = true
}

# --- 6. Dataflow Staging Buckets ---
# Dataflow needs a place to store temp files during job execution
resource "google_storage_bucket" "dataflow_temp" {
  for_each = var.environments

  name          = "bkt-clin-syn-df-temp-${each.key}-${local.project_id}"
  project       = local.project_id
  location      = var.data_location
  force_destroy = false
  
  uniform_bucket_level_access = true
}