##############################################
# PUBSUB TOPICS — ONE PER DOMAIN PROJECT
##############################################

resource "google_pubsub_topic" "df_ingest_topic" {
  for_each = local.domain_projects

  name    = "df-ingest-${each.key}"
  project = local.project_ids[each.key]

  lifecycle {
    prevent_destroy = true
  }
}



output "df_ingest_topics" {
  value = {
    for k, t in google_pubsub_topic.df_ingest_topic :
    k => t.name
  }
}

##############################################
# SUBSCRIPTIONS — ONE PER ENV (shared projects)
##############################################

resource "google_pubsub_subscription" "df_ingest_sub" {
  for_each = local.shared_projects

  name    = "df-ingest-sub-${each.key}"
  project = local.project_ids[each.value]

  topic = google_pubsub_topic.df_ingest_topic[
    one([
      for domain_key in keys(local.domain_projects) :
      domain_key
      if endswith(domain_key, "_${each.key}")
    ])
  ].id


  ack_deadline_seconds       = 30
  message_retention_duration = "86400s"
  retain_acked_messages      = false

  lifecycle {
    prevent_destroy = true
  }
}

output "df_ingest_subscriptions" {
  value = {
    for env, sub in google_pubsub_subscription.df_ingest_sub :
    env => sub.name
  }
}

##############################################
# IAM — DATAFLOW RUNNER SA CAN PULL MESSAGES
##############################################

resource "google_pubsub_subscription_iam_member" "df_subscriber" {
  for_each = local.shared_projects   # np, pd

  project      = local.project_ids[each.value]
  subscription = google_pubsub_subscription.df_ingest_sub[each.key].name
  role         = "roles/pubsub.subscriber"

  member       = "serviceAccount:${google_service_account.df_runner[each.key].email}"
}

##############################################
# IAM — CLOUD FUNCTION / PIPELINE SA CAN PUBLISH
##############################################

resource "google_pubsub_topic_iam_member" "domain_publisher" {
  for_each = local.domain_projects

  project = local.project_ids[each.key]
  topic   = google_pubsub_topic.df_ingest_topic[each.key].name
  role    = "roles/pubsub.publisher"

  member = "serviceAccount:${local.pipeline_sas[each.key]}"
}

##############################################
# CRITICAL: GCS NEEDS PERMISSION TO PUBLISH
##############################################

data "google_storage_project_service_account" "gcs_account" {}

resource "google_pubsub_topic_iam_member" "gcs_pubsub_publisher" {
  for_each = local.domain_projects

  project = local.project_ids[each.key]
  topic   = google_pubsub_topic.df_ingest_topic[each.key].name
  role    = "roles/pubsub.publisher"

  member = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}

