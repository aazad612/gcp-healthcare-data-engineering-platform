resource "google_iam_workload_identity_pool" "github_pool" {
  project                   = local.hub_project
  workload_identity_pool_id = "github-actions-pool-v2"
  display_name              = "GitHub Actions WIF Pool V2"
  description               = "Central WIF Pool for GitHub Actions CI/CD"
}

variable "github_repo_owner" {
  description = "The GitHub organization or user name that owns the repository (e.g., 'my-org')."
  type        = string
  default     = "aazad612"
}

variable "github_repository" {
  description = "The specific repository name (e.g., 'terraform-cicd-repo')."
  type        = string
  default     = "gcp-healthcare-data-platform"
}


resource "google_iam_workload_identity_pool_provider" "github_provider" {
  project                            = local.hub_project
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-oidc-provider"
  display_name                       = "GitHub OIDC Provider"

  attribute_mapping = {
    "google.subject"       = "assertion.sub",
    "attribute.actor"      = "assertion.actor",
    "attribute.repository" = "assertion.repository"
  }

oidc {
    issuer_uri = "https://token.actions.githubusercontent.com" 
  }
  # --- CRUCIAL: Restrict access to your single repository ---
  attribute_condition = "assertion.repository == \"${var.github_repo_owner}/${var.github_repository}\""
}

resource "google_service_account_iam_member" "github_wif_impersonator" {
  # Target: The central Jenkins Deployer SA
  service_account_id = google_service_account.jenkins_deployer_sa.name

  # Role: Grants the right to authenticate as the Service Account
  role = "roles/iam.workloadIdentityUser"

  # Member: The GitHub identity tied to your pool and provider
  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo_owner}/${var.github_repository}"
}


output "workload_identity_provider_id" {
  description = "The fully qualified resource name for the WIF Provider."
  value       = google_iam_workload_identity_pool_provider.github_provider.name
}

output "service_account_email" {
  description = "The email of the Service Account that GitHub Actions will impersonate."
  value       = google_service_account.jenkins_deployer_sa.email
}