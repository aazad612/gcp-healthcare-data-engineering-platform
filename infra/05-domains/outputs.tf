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

