output "project_id" {
  description = "The Service Project ID where resources were deployed."
  value       = local.project_id
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
  description = "Map of Interface (View) Dataset IDs per environment. Connect Tableau here."
  value       = { for env, ds in google_bigquery_dataset.interface : env => ds.dataset_id }
}

output "data_lake_buckets" {
  description = "Map of Data Lake Bucket names per environment."
  value       = { for env, bkt in google_storage_bucket.data_lake : env => bkt.name }
}

output "dataflow_temp_buckets" {
  description = "Map of Dataflow Temp Bucket names per environment."
  value       = { for env, bkt in google_storage_bucket.dataflow_temp : env => bkt.name }
}