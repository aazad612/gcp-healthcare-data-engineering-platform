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

data "google_project" "shared_projects_info" {
  for_each   = local.shared_projects
  project_id = local.project_ids[each.value]
}


resource "google_service_account_iam_member" "df_agent_impersonation" {
  for_each = local.shared_projects

  # TARGET: Your existing Runner SA
  service_account_id = google_service_account.df_runner[each.key].name
  
  # ROLE: Service Account User
  role               = "roles/iam.serviceAccountUser"
  
  # ACTOR: Google's Hidden Robot Account
  member             = "serviceAccount:service-${data.google_project.shared_projects_info[each.key].number}@dataflow-service-producer-prod.iam.gserviceaccount.com"
}

# --------------------------------------------------------
# 6. BigQuery Job User on Spoke Projects (THE FIX)
#    Allows the Runner to execute SQL queries inside the
#    application projects (Synthea, Hospital, etc.)
# --------------------------------------------------------
resource "google_project_iam_member" "runner_bq_job_user_services" {
  for_each = local.domain_projects

  # The Spoke Project (e.g., prj-clin-syn-np)
  project = local.project_ids[each.key]
  
  # The Role: Allows running queries (jobs.create)
  role    = "roles/bigquery.jobUser"

  # The Member: Pick the correct Runner (PD vs NP)
  member = (local.domain_to_env[each.key] == "pd" || local.domain_to_env[each.key] == "prod") ? "serviceAccount:${google_service_account.df_runner["pd"].email}" : "serviceAccount:${google_service_account.df_runner["np"].email}"
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


resource "google_project_iam_member" "df_bq_domain_editor" {
  for_each = local.domain_projects

  project = local.project_ids[each.key]
  role    = "roles/bigquery.dataEditor"

  member = "serviceAccount:${google_service_account.df_runner[local.domain_to_env[each.key]].email}"
}


# Grant Access to Data Lakes (Using REAL names from Synthea)
resource "google_storage_bucket_iam_member" "df_raw_admin" {
  # Loop through the outputs you pasted: {"dev": "...", "qa": "...", "uat": "..."}
  for_each = data.terraform_remote_state.synthea.outputs.data_lake_buckets

  bucket = each.value
  role   = "roles/storage.objectAdmin"

  # Logic: If the env key is 'prod' or 'pd', use PD runner. Otherwise (dev, qa, uat) use NP runner.
  member = (each.key == "prod" || each.key == "pd") ? "serviceAccount:${google_service_account.df_runner["pd"].email}" : "serviceAccount:${google_service_account.df_runner["np"].email}"
}