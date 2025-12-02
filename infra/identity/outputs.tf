// outputs.tf
output "user_emails" {
  description = "Map of user keys to primary emails."
  value       = { for k, u in var.identity_users : k => u.primary_email }
  sensitive   = false
}

output "group_emails" {
  description = "Map of group keys to group email addresses."
  value       = { for k, g in var.identity_groups : k => g.email }
  sensitive   = false
}
