impersonate_service_account = "johneysadmin@johneysadminproject.iam.gserviceaccount.com"
billing_account_id          = "01D9F1-90D8BC-2AE0A2"
org_id                      = "9139207439"

service_projects = {
  # --- 1. SHARED SERVICES (Airflow, Data Catalog, Cloud Build) ---
  # This hosts the "Brains" of the platform.
  # shared_orch_pd = {
  #   project_id       = "prj-shared-orch-pd"
  #   folder_key       = "shared_services"
  #   host_project_key = "hub"
  #   subnet_key       = "hub_main"
  #   apis             = [
  #     "composer.googleapis.com",       # Airflow
  #     "cloudbuild.googleapis.com",     # CI/CD
  #     "artifactregistry.googleapis.com", # Docker images for dbt/Python
  #     "datacatalog.googleapis.com",    # Central Governance
  #     "dlp.googleapis.com",            # PII Scanner
  #     "secretmanager.googleapis.com"   # DB Credentials
  #   ]
  # }

  # shared_orch_np = {
  #   project_id       = "prj-shared-orch-np"
  #   folder_key       = "shared_services"
  #   host_project_key = "hub"
  #   subnet_key       = "hub_main"
  #   apis             = [
  #     "compute.googleapis.com",
  #     "composer.googleapis.com",       # Airflow
  #     "cloudbuild.googleapis.com",     # CI/CD
  #     "artifactregistry.googleapis.com", # Docker images for dbt/Python
  #     "datacatalog.googleapis.com",    # Central Governance
  #     "dlp.googleapis.com",            # PII Scanner
  #     "secretmanager.googleapis.com"   # DB Credentials
  #   ]
  # }

  shared_pd = {
    project_id       = "prj-lbd-shared-pd"
    folder_key       = "shared_services"
    host_project_key = "hub"
    subnet_key       = "hub_main"
    apis = [
      "composer.googleapis.com",         # Airflow
      "cloudbuild.googleapis.com",       # CI/CD
      "artifactregistry.googleapis.com", # Docker images for dbt/Python
      "datacatalog.googleapis.com",      # Central Governance
      "dlp.googleapis.com",              # PII Scanner
      "secretmanager.googleapis.com",    # DB Credentials
      "storage.googleapis.com"           # DB Credentials
    ]
  }

  shared_np = {
    project_id       = "prj-lbd-shared-np"
    folder_key       = "shared_services"
    host_project_key = "hub"
    subnet_key       = "hub_main"
    apis = [
      "compute.googleapis.com",
      "composer.googleapis.com",         # Airflow
      "cloudbuild.googleapis.com",       # CI/CD
      "artifactregistry.googleapis.com", # Docker images for dbt/Python
      "datacatalog.googleapis.com",      # Central Governance
      "dlp.googleapis.com",              # PII Scanner
      "secretmanager.googleapis.com",    # DB Credentials
      "storage.googleapis.com"           # DB Credentials
    ]
  }

  # --- 2. CLINICAL DOMAIN (Synthea) - NON-PROD ---
  # Hosts Dev, Test, and QA datasets (separated by dataset suffix, e.g., _dev, _qa)
  # This saves quota compared to creating 3 separate projects.
  clin_syn_np = {
    project_id       = "prj-clin-syn-np"
    folder_key       = "healthcare_platform"
    host_project_key = "clinical"
    subnet_key       = "clin_int"
    apis = [
      "bigquery.googleapis.com",
      "dataflow.googleapis.com",
      "storage-component.googleapis.com",
      "pubsub.googleapis.com",         # Streaming ingestion
      "cloudfunctions.googleapis.com", # Event-based triggers
      "run.googleapis.com",            # Data Contracts / API
      "dlp.googleapis.com"             # Local PII scanning
    ]
  }

  # --- 3. CLINICAL DOMAIN (Synthea) - PROD ---
  clin_syn_pd = {
    project_id       = "prj-clin-syn-pd"
    folder_key       = "healthcare_platform"
    host_project_key = "clinical"
    subnet_key       = "clin_int"
    apis = [
      "bigquery.googleapis.com",
      "dataflow.googleapis.com",
      "storage-component.googleapis.com",
      "pubsub.googleapis.com",
      "cloudfunctions.googleapis.com",
      "run.googleapis.com",
      "dlp.googleapis.com"
    ]
  }
}