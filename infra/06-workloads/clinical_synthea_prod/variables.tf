variable "impersonate_service_account" {
  description = "Service Account to impersonate."
  type        = string
}

variable "target_project_key" {
  description = "Logical key from Layer 05 (e.g., clin_syn_np)."
  type        = string
}

variable "environments" {
  description = "List of environments to deploy (e.g., ['dev', 'test', 'qa'])."
  type        = set(string)
}

variable "data_location" {
  description = "Region for Datasets and Buckets."
  type        = string
  default     = "US"
}