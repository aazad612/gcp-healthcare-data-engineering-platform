locals {
  default_apis = [
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "storage.googleapis.com",
    "iam.googleapis.com",
    "cloudbuild.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-component.googleapis.com",
    "eventarc.googleapis.com",
    "pubsub.googleapis.com",
    "compute.googleapis.com" ]
}


module "service_projects" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 15.0"

  for_each = var.service_projects

  name       = each.value.project_id
  project_id = each.value.project_id
  org_id     = var.org_id

  folder_id = local.folder_ids[each.value.folder_key]

  billing_account = var.billing_account_id

  svpc_host_project_id = local.host_project_ids[each.value.host_project_key]

  sa_role = "roles/editor"

  shared_vpc_subnets = [
    local.subnet_ids[each.value.subnet_key]
  ]



  # DYNAMIC CONFIGURATION
  # 1. Use the specific list from tfvars
  activate_apis = distinct(concat(local.default_apis, each.value.apis))

  # 2. (Optional) Disable the default APIs if you want strict control
  # If false, the module automatically adds compute, container, etc.
  disable_services_on_destroy = false
}

variable "project_sa_roles" {
  type = list(string)
  default = [
    "roles/bigquery.jobUser",
    "roles/bigquery.dataOwner",
    "roles/bigquery.admin",
    "roles/storage.objectAdmin",
    "roles/pubsub.admin",
    "roles/eventarc.publisher",
    "roles/eventarc.eventReceiver",
    "roles/iam.serviceAccountUser"
  ]
}

locals {
  project_sa_role_bindings = {
    for item in flatten([
      for proj_key, proj in var.service_projects : [
        for role in var.project_sa_roles : {
          key        = "${proj_key}-${role}"
          project_id = proj.project_id
          role       = role
        }
      ]
    ]) : item.key => item
  }
}


resource "google_project_iam_member" "project_sa_roles" {
  for_each = local.project_sa_role_bindings

  project = each.value.project_id
  role    = each.value.role
  member  = "serviceAccount:project-service-account@${each.value.project_id}.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "shared_bq_user" {
  for_each = var.service_projects

  project = "prj-lbd-shared-np"
  role    = "roles/bigquery.user"
  member  = "serviceAccount:project-service-account@${each.value.project_id}.iam.gserviceaccount.com"
}


# Data source to fetch project number for all NP service projects (used for SA construction)
data "google_project" "np_service_projects_info" {
  for_each = local.np_service_projects
  project_id = each.value.project_id
}

# Data source to fetch project number for all PD service projects
data "google_project" "pd_service_projects_info" {
  for_each = local.pd_service_projects
  project_id = each.value.project_id
}




# resource "google_project_iam_member" "np_gcs_eventarc_publisher" {
#   for_each = local.np_service_projects # Iterate over all NP service projects

#   # Project where the permission is granted (the spoke project itself)
#   project = each.value.project_id
  
#   # Role required by GCS to send events via Pub/Sub
#   role    = "roles/pubsub.publisher"

#   # The GCS Service Account requires the Project Number for the member field.
#   # Assuming your 'each.value' contains a 'project_number' attribute:
#   member  = "serviceAccount:service-${data.google_project.np_service_projects_info[each.key].number}@gs-project-accounts.iam.gserviceaccount.com"
# }



resource "google_project_iam_member" "np_gcs_eventarc_publisher" {
  for_each = local.np_service_projects

  project = each.value.project_id
  
  role = "roles/pubsub.publisher"

  member = "serviceAccount:service-${data.google_project.np_service_projects_info[each.key].number}@gs-project-accounts.iam.gserviceaccount.com"
  
}



resource "google_project_iam_member" "pd_gcs_eventarc_publisher" {
  for_each = local.pd_service_projects

  project = each.value.project_id
  role    = "roles/pubsub.publisher"

  member = "serviceAccount:service-${data.google_project.pd_service_projects_info[each.key].number}@gs-project-accounts.iam.gserviceaccount.com"
}
