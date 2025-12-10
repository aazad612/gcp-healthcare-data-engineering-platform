variable "impersonate_service_account" {
  type = string
}

variable "target_projects" {
  description = "Map of Environment Name to Logical Project Key (from Layer 05)"
  type        = map(string)
  # Example: { np = "shared_orch_np", pd = "shared_orch_pd" }
}

variable "data_location" {
  description = "Region for the dataset"
  default     = "US"
}