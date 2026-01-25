
resource "google_pubsub_topic" "ingestion_topic" {
  for_each = var.environments

  name    = "topic-synthea-ingestion-${each.key}"
  project = local.env_project_ids[each.key]
}

resource "google_pubsub_topic_iam_binding" "binding" {
  for_each = var.environments

  topic   = google_pubsub_topic.ingestion_topic[each.key].id
  role    = "roles/pubsub.publisher"
  
  # FIX: Use the GCS SA Map we created in data.tf
  members = ["serviceAccount:${local.env_gcs_service_accounts[each.key]}"]
}

resource "google_storage_notification" "bucket_notification" {
  for_each = var.environments

  bucket         = google_storage_bucket.data_lake[each.key].name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.ingestion_topic[each.key].id
  event_types    = ["OBJECT_FINALIZE"]

  depends_on = [google_pubsub_topic_iam_binding.binding]
}

resource "google_pubsub_subscription" "dataflow_sub" {
  for_each = var.environments

  name    = "sub-dataflow-ingest-${each.key}"
  project = local.env_project_ids[each.key]
  topic   = google_pubsub_topic.ingestion_topic[each.key].id

  ack_deadline_seconds = 600
  
  expiration_policy {
    ttl = "" 
  }
}