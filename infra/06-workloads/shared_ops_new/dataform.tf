data "google_project" "shared_np" {
  project_id = local.project_ids["shared_np"]
}

resource "google_project_service" "dataform_api" {
  project = data.google_project.shared_np.project_id
  service = "dataform.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "dataform_runtime" {
  project      = data.google_project.shared_np.project_id
  account_id   = "sa-dataform-nonprod"
  display_name = "Dataform Runtime SA Nonprod"
}

# resource "google_dataform_repository" "clinical_nonprod" {
#   provider = google-beta
#   project = data.google_project.shared_np.project_id
#   region  = var.region
#   name    = "clinical-nonprod"

#   labels = {
#     domain = "clinical"
#     env    = "nonprod"
#   }

#   depends_on = [
#     google_project_service.dataform_api
#   ]
# }

resource "google_dataform_repository_iam_member" "dataform_admin" {
  provider = google-beta
  project    = data.google_project.shared_np.project_id
  region     = var.region
  repository = google_dataform_repository.clinical_nonprod.name
  role       = "roles/dataform.admin"
  member     = "serviceAccount:${google_service_account.dataform_runtime.email}"
}

resource "google_service_account_iam_member" "dataform_impersonates_project_sa" {
  for_each = local.domain_projects

  service_account_id = "projects/${local.project_ids[each.key]}/serviceAccounts/${local.pipeline_sas[each.key]}"
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.dataform_runtime.email}"
}

resource "google_service_account_iam_member" "dataform_impersonates_shared_sa" {
  service_account_id = "projects/${data.google_project.shared_np.project_id}/serviceAccounts/${local.pipeline_sas["shared_np"]}"  
  role   = "roles/iam.serviceAccountTokenCreator"
  member = "serviceAccount:${google_service_account.dataform_runtime.email}"
}

resource "google_service_account_iam_member" "dataform_agent_impersonates_shared_sa" {
  service_account_id = "projects/${data.google_project.shared_np.project_id}/serviceAccounts/${local.pipeline_sas["shared_np"]}"  
  role   = "roles/iam.serviceAccountTokenCreator"
  member = "serviceAccount:service-${local.project_numbers["shared_np"]}@gcp-sa-dataform.iam.gserviceaccount.com"
}

locals {
  # Define your environment-to-branch mapping in one place
  dataform_environments = {
    "pd" = "main"
    "np"  = "dev"
    "qa"   = "qa"
    "uat" = "test"
  }
}

resource "google_dataform_repository_release_config" "clinical" {
  provider = google-beta
  for_each = local.dataform_environments

  project    = data.google_project.shared_np.project_id
  region     = var.region
  repository = google_dataform_repository.clinical_nonprod.name
  
  # Dynamic naming: clinical-main, clinical-dev, etc.
  name       = "clinical-${each.key}"

  # Dynamic branch targeting
  git_commitish = each.value

  # Optional: standardizing compilation settings across all releases
  code_compilation_config {
    default_database = data.google_project.shared_np.project_id

    vars = {
      execution_env = each.key
    }
  }
}

resource "google_dataform_repository_workflow_config" "clinical_manual" {
  provider = google-beta
  for_each = local.domain_projects

  project    = data.google_project.shared_np.project_id
  region     = var.region
  repository = google_dataform_repository.clinical_nonprod.name
  name       = "clinical-${each.key}"
  
  release_config = google_dataform_repository_release_config.clinical[local.domain_suffix_new[each.key]].id

  invocation_config {
    included_tags                    = ["clinical"]
    service_account                 = local.pipeline_sas[each.key]
    transitive_dependencies_included = true
  }
}


resource "google_secret_manager_secret_iam_member" "dataform_ssh_accessor" {
  project   = data.google_project.shared_np.project_id
  secret_id = google_secret_manager_secret.dataform_ssh_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.dataform_runtime.email}"
}

resource "google_secret_manager_secret_iam_member" "dataform_agent_ssh_accessor" {
  project   = data.google_project.shared_np.project_id
  secret_id = google_secret_manager_secret.dataform_ssh_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:service-${local.project_numbers["shared_np"]}@gcp-sa-dataform.iam.gserviceaccount.com"
}

variable "github_ssh_private_key" {
  type = string
}

variable "github_host_public_key" {
  type = string
  default = "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
}

variable "git_url" {
  type = string
  default = "git@github.com:aazad612/gcp-healthcare-data-platform.git"
}

resource "google_secret_manager_secret" "dataform_ssh_key" {
  provider  = google-beta
  project   = data.google_project.shared_np.project_id
  secret_id = "clinical-dataform-ssh-key"

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "ssh_key_version" {
  secret      = google_secret_manager_secret.dataform_ssh_key.id
  # Ensure the variable contains the raw private key content
  secret_data = var.github_ssh_private_key 
}

resource "google_dataform_repository" "clinical_nonprod" {
  provider = google-beta
  project  = data.google_project.shared_np.project_id
  region   = var.region
  name     = "clinical-nonprod"

  git_remote_settings {
    url            = var.git_url
    default_branch = "dev"

    ssh_authentication_config {
      user_private_key_secret_version = google_secret_manager_secret_version.ssh_key_version.id
      host_public_key                 = var.github_host_public_key 
    }
  }

  workspace_compilation_overrides {
    default_database                = data.google_project.shared_np.project_id
  }
}

output "dataform_repository_name" {
  value = google_dataform_repository.clinical_nonprod.name
}

output "dataform_runtime_service_account" {
  value = google_service_account.dataform_runtime.email
}
