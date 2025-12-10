output "ops_dataset_ids" {
  description = "Map of created Ops Datasets per environment"
  value = {
    for env, ds in google_bigquery_dataset.ops_metadata :
    env => "${ds.project}.${ds.dataset_id}"
  }
}