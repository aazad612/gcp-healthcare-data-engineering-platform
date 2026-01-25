output "project_ids" {
  description = "Map of created Service Project IDs."
  value       = { for k, v in module.service_projects : k => v.project_id }
}

output "service_accounts" {
  description = "Map of Default Service Accounts (useful for IAM)."
  value       = { for k, v in module.service_projects : k => v.service_account_email }
}

output "project_numbers" {
  value = { for k, v in module.service_projects : k => v.project_number }
}

# Export the GCS Service Account email so Layer 06 can use it for permissions
output "gcs_service_accounts" {
  description = "Map of GCS Service Account emails per project key."
  value = {
    # This iterates over the projects you just created to find their unique GCS email
    for k, v in module.service_projects : k => "service-${v.project_number}@gs-project-accounts.iam.gserviceaccount.com"
  }
}

# output "dataflow_worker_service_accounts" {
#   description = "Map of dedicated Dataflow Worker Service Accounts (np/pd) created in Shared Projects."
#   value = {
#     for k, v in google_service_account.dataflow_worker : k => v.email
#   }
# }