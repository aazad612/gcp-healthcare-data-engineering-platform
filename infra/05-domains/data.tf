# Read Layer 01 (Folders)
data "terraform_remote_state" "org" {
  backend = "gcs"
  config = {
    bucket = "johneys-tf-states"
    prefix = "healthcare-landing-zone/01-organization"
  }
}

# Read Layer 03 (Networking)
data "terraform_remote_state" "net" {
  backend = "gcs"
  config = {
    bucket = "johneys-tf-states"
    prefix = "healthcare-landing-zone/03-networking"
  }
}

locals {
  # These maps allow us to look up "networking" -> "folders/12345"
  folder_ids       = data.terraform_remote_state.org.outputs.folder_ids
  host_project_ids = data.terraform_remote_state.net.outputs.host_project_ids
  subnet_ids       = data.terraform_remote_state.net.outputs.subnet_ids
  vpc_ids          = data.terraform_remote_state.net.outputs.vpc_ids
}

locals {
  # Auto-detect NP & PD service projects based on project_id suffix
  np_service_projects = {
    for k, v in var.service_projects :
    k => v if can(regex(".*-(np|dev|qa|uat)$", v.project_id))
  }

  pd_service_projects = {
    for k, v in var.service_projects :
    k => v if can(regex(".*-pd$", v.project_id))
  }

  # Shared project identifiers
  shared_np_project = var.service_projects["shared_np"].project_id
  shared_pd_project = var.service_projects["shared_pd"].project_id
}