# locals {
#   # Map Shared Projects for cleaner looping
#   shared_envs = {
#     np = local.shared_np_project
#     pd = local.shared_pd_project
#   }
# }

# # # --------------------------------------------------------
# # # 1. Create the Dataflow Worker Service Account
# # #    (Created in Shared NP and Shared PD)
# # # --------------------------------------------------------
# # resource "google_service_account" "dataflow_worker" {
# #   for_each = local.shared_envs

# #   project      = each.value
# #   account_id   = "dataflow-worker"
# #   display_name = "Dataflow Worker for ${upper(each.key)} Environment"
# # }

# # # --------------------------------------------------------
# # # 2. Grant Permissions on the SHARED Project
# # #    (Allows it to write logs, metrics, and spin up VMs)
# # # --------------------------------------------------------
# # resource "google_project_iam_member" "df_worker_shared_roles" {
# #   for_each = local.shared_envs

# #   project = each.value
# #   role    = "roles/dataflow.worker"
# #   member  = "serviceAccount:${google_service_account.dataflow_worker[each.key].email}"
# # }

# # --------------------------------------------------------
# # 3. The "Service Agent" Fix (Crucial for Custom SAs)
# #    Allows Google's Cloud Dataflow Robot to act as this new SA
# # --------------------------------------------------------
# # First, get project numbers for the Service Agent email
# data "google_project" "shared_projects_info" {
#   for_each   = local.shared_envs
#   project_id = each.value
# }


# resource "google_service_account_iam_member" "df_agent_impersonation" {
#   for_each = local.shared_envs

#   # The Resource: Your new Worker SA
#   service_account_id = google_service_account.dataflow_worker[each.key].name
  
#   # The Role: Service Agent Role
#   role               = "roles/dataflow.serviceAgent"
  
#   # The Member: Google's hidden Robot Account
#   member             = "serviceAccount:service-${data.google_project.shared_projects_info[each.key].number}@dataflow-service-producer-prod.iam.gserviceaccount.com"
# }

# # --------------------------------------------------------
# # 4. Enable Impersonation (The "Key")
# #    Shared Worker (Actor) -> Spoke SA (Target)
# # --------------------------------------------------------

# # NON-PROD: Shared NP Worker can impersonate Dev, QA, UAT SAs
# # resource "google_service_account_iam_member" "np_worker_impersonates_service" {
# #   for_each = local.np_service_projects

# #   # TARGET: The Spoke Project's Default Service Account
# #   # (Must match the SA created in your service project module)
# #   service_account_id = "projects/${each.value.project_id}/serviceAccounts/project-service-account@${each.value.project_id}.iam.gserviceaccount.com"
  
# #   role = "roles/iam.serviceAccountTokenCreator"

# #   # ACTOR: The Shared NP Worker
# #   member = "serviceAccount:${google_service_account.dataflow_worker["np"].email}"
# # }

# # # PROD: Shared PD Worker can impersonate Prod SA
# # resource "google_service_account_iam_member" "pd_worker_impersonates_service" {
# #   for_each = local.pd_service_projects

# #   # TARGET: The Spoke Project's Default Service Account
# #   service_account_id = "projects/${each.value.project_id}/serviceAccounts/project-service-account@${each.value.project_id}.iam.gserviceaccount.com"
  
# #   role = "roles/iam.serviceAccountTokenCreator"

# #   # ACTOR: The Shared PD Worker
# #   member = "serviceAccount:${google_service_account.dataflow_worker["pd"].email}"
# # }


# # # File: storage.tf (or iam_dataflow.tf) in the Shared Project layer

# # resource "google_storage_bucket_iam_member" "worker_temp_admin" {
# #   # The bucket from your error log
# #   bucket = "bkt-df-temp-np-prj-lbd-shared-np" 
  
# #   # Admin is required for "Delete" operations (Renames)
# #   role   = "roles/storage.objectAdmin"

# #   # The NP Worker we created earlier
# #   member = "serviceAccount:${google_service_account.dataflow_worker["np"].email}"
# # }