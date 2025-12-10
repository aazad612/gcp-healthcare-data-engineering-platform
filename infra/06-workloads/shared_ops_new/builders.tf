variable "region" {
  default = "us-central1"
}


# ─── Create 1 repo per environment (np/pd) ──────────────────────
resource "google_artifact_registry_repository" "deployer" {
  for_each = var.target_projects # np → shared_np, pd → shared_pd

  project       = local.project_ids[each.value]
  location      = var.region
  repository_id = "${each.key}-build-deployers"
  format        = "DOCKER"
  description   = "SQL deployer & CI helper images (${each.key})"
}

# ─── Compute Cloud Build SA emails ─────────────────────────────
data "google_project" "env_project" {
  for_each   = var.target_projects
  project_id = local.project_ids[each.value]
}


# ─── Grant Cloud Build write access ────────────────────────────
resource "google_artifact_registry_repository_iam_member" "cb_writer" {
  for_each = var.target_projects

  project    = local.project_ids[each.value]
  location   = var.region
  repository = google_artifact_registry_repository.deployer[each.key].repository_id

  role   = "roles/artifactregistry.writer"
  member = "serviceAccount:${local.cloudbuild_sas[each.key]}"
}

# ─── Output repo URLs ──────────────────────────────────────────
output "deployer_repos" {
  value = {
    for env, v in google_artifact_registry_repository.deployer :
    env => "${var.region}-docker.pkg.dev/${local.project_ids[var.target_projects[env]]}/${v.repository_id}"
  }
}
