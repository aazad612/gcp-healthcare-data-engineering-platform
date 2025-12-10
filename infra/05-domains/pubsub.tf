locals {
  data_projects = {
    for k, v in var.service_projects :
    k => v
    if !contains(["shared_np", "shared_pd"], k)
  }
}

resource "google_pubsub_topic" "bronze_ingest_request" {
  for_each = local.data_projects

  name    = "bronze_ingest_request"
  project = each.value.project_id
}

resource "google_pubsub_topic_iam_member" "cf_publisher" {
  for_each = local.data_projects

  project = each.value.project_id
  topic   = google_pubsub_topic.bronze_ingest_request[each.key].name
  role    = "roles/pubsub.publisher"

  member = "serviceAccount:project-service-account@${each.value.project_id}.iam.gserviceaccount.com"
}


