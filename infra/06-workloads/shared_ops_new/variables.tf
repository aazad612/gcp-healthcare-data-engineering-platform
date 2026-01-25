variable "impersonate_service_account" {
  type = string
}

variable "target_projects" {
  description = "Map of Environment Name to Logical Project Key (from Layer 05)"
  type        = map(string)
}

variable "data_location" {
  description = "Region for the dataset"
  default     = "US"
}

