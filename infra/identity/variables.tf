variable "cloud_identity_customer_id" {
  description = "Cloud Identity customer ID (e.g., C0123abcd)."
  type        = string
}

variable "admin_impersonation_email" {
  description = "Admin user email to impersonate for managing users and groups."
  type        = string
}

variable "identity_users" {
  description = <<EOT
Map of user keys to user definitions.
Each entry:
- primary_email
- given_name
- family_name
- recovery_email
- org_unit_path
EOT
  type = map(object({
    primary_email  = string
    given_name     = string
    family_name    = string
    recovery_email = string
    org_unit_path  = string
  }))
}

variable "identity_passwords" {
  description = "Map of user key to initial password (sensitive)."
  type        = map(string)
  sensitive   = true
}

variable "identity_groups" {
  description = <<EOT
Map of group keys to group definitions.
Each entry:
- email
- name
- description
EOT
  type = map(object({
    email       = string
    name        = string
    description = string
  }))
}

variable "group_memberships" {
  description = <<EOT
Map of membership keys to membership definitions.
Each entry:
- user_key: key from identity_users
- group_key: key from identity_groups
- role: one of OWNER, MANAGER, MEMBER
EOT
  type = map(object({
    user_key  = string
    group_key = string
    role      = string
  }))
}
