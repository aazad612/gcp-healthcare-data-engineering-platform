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
  # Authentication is handled via ADC, a service account key, or workforce identity.
  # No hardcoded credentials here.
  customer_id             = var.cloud_identity_customer_id
  impersonated_user_email = var.admin_impersonation_email
}
