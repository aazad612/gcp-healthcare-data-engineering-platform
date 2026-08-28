terraform {
  required_version = ">= 1.6.0"

  required_providers {
    googleworkspace = {
      source  = "hashicorp/googleworkspace"
      version = "~> 0.7"
    }
  }
}

provider "googleworkspace" {
  customer_id             = var.cloud_identity_customer_id
  impersonated_user_email = var.admin_impersonation_email

  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.user",
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.group.member",
    "https://www.googleapis.com/auth/admin.directory.orgunit"
  ]
}
