###########################################
# DATAFLOW RUNNER SERVICE ACCOUNTS (Shared)
###########################################

resource "google_service_account" "df_runner" {
  for_each = local.shared_projects

  account_id   = "df-runner-${each.key}"
  display_name = "Dataflow Runner (${each.key})"

  # Runs inside the shared project
  project = local.project_ids[each.value]

  lifecycle {
    prevent_destroy = true
  }
}

output "df_runner_service_accounts" {
  value = {
    for env, sa in google_service_account.df_runner :
    env => sa.email
  }
}

###########################################
# DATAFLOW WORKER IAM (Shared Projects)
###########################################

resource "google_project_iam_member" "df_worker" {
  for_each = local.shared_projects

  project = local.project_ids[each.value]
  role    = "roles/dataflow.worker"

  member = "serviceAccount:${google_service_account.df_runner[each.key].email}"
}

resource "google_project_iam_member" "df_bq_jobuser" {
  for_each = local.shared_projects

  project = local.project_ids[each.value]
  role    = "roles/bigquery.jobUser"

  member = "serviceAccount:${google_service_account.df_runner[each.key].email}"
}

resource "google_project_iam_member" "df_bq_dataeditor_shared" {
  for_each = local.shared_projects

  project = local.project_ids[each.value]
  role    = "roles/bigquery.dataEditor"

  member = "serviceAccount:${google_service_account.df_runner[each.key].email}"
}

###########################################
# DATAFLOW — BigQuery Editor in DOMAIN PROJECTS
###########################################

resource "google_project_iam_member" "df_bq_domain_editor" {
  for_each = local.domain_projects

  project = local.project_ids[each.key]
  role    = "roles/bigquery.dataEditor"

  member = "serviceAccount:${google_service_account.df_runner[local.domain_to_env[each.key]].email}"
}
