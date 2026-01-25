output "project_ids" {
  description = "The Service Project IDs where resources were deployed, per environment."
  value       = local.env_project_ids
}

output "bronze_datasets" {
  description = "Map of Bronze (Raw) Dataset IDs per environment."
  value       = { for env, ds in google_bigquery_dataset.bronze : env => ds.dataset_id }
}

output "silver_datasets" {
  description = "Map of Silver (Clean) Dataset IDs per environment."
  value       = { for env, ds in google_bigquery_dataset.silver : env => ds.dataset_id }
}

output "gold_datasets" {
  description = "Map of Gold (Aggregated) Dataset IDs per environment."
  value       = { for env, ds in google_bigquery_dataset.gold : env => ds.dataset_id }
}

output "interface_datasets" {
  description = "Map of Interface (View) Dataset IDs per environment."
  value       = { for env, ds in google_bigquery_dataset.interface : env => ds.dataset_id }
}

output "data_lake_buckets" {
  description = "Map of Data Lake Bucket names per environment."
  value       = { for env, bkt in google_storage_bucket.data_lake : env => bkt.name }
}

