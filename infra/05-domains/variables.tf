variable "impersonate_service_account" { type = string }
variable "billing_account_id" { type = string }
variable "org_id" { type = string }

variable "service_projects" {
  description = "Map of Service Projects with specific APIs."
  type = map(object({
    project_id       = string
    folder_key       = string
    host_project_key = string
    subnet_key       = string
    apis             = list(string)
  }))
}