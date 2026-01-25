locals {
  default_apis = [
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "storage.googleapis.com",
    "iam.googleapis.com",
    "cloudbuild.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-component.googleapis.com",
    "cloudresourcemanager.googleapis.com",
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
    "roles/iam.serviceAccountUser",
    "roles/cloudfunctions.admin",
    "roles/run.admin",
    "roles/artifactregistry.writer",
    "roles/serviceusage.serviceUsageConsumer"
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
  depends_on = [module.service_projects]
}

resource "google_project_iam_member" "shared_bq_user" {
  for_each = var.service_projects

  project = "prj-lbd-shared-np"
  role    = "roles/bigquery.user"
  member  = "serviceAccount:project-service-account@${each.value.project_id}.iam.gserviceaccount.com"
  depends_on = [module.service_projects]
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


resource "google_project_iam_member" "shared_np_eventarc_agent" {
  project = local.shared_np_project
  role    = "roles/eventarc.serviceAgent"
  member  = "serviceAccount:service-${data.google_project.np_service_projects_info["shared_np"].number}@gcp-sa-eventarc.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "shared_pd_eventarc_agent" {
  project = local.shared_pd_project
  role    = "roles/eventarc.serviceAgent"
  member  = "serviceAccount:service-${data.google_project.pd_service_projects_info["shared_pd"].number}@gcp-sa-eventarc.iam.gserviceaccount.com"
}

# 2. Fix Runtime ActAs (The "Gen 2 Runtime" fix)
resource "google_service_account_iam_member" "shared_np_sa_act_as_compute" {
  service_account_id = "projects/${local.shared_np_project}/serviceAccounts/${data.google_project.np_service_projects_info["shared_np"].number}-compute@developer.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:project-service-account@${local.shared_np_project}.iam.gserviceaccount.com"
}

resource "google_service_account_iam_member" "shared_pd_sa_act_as_compute" {
  service_account_id = "projects/${local.shared_pd_project}/serviceAccounts/${data.google_project.pd_service_projects_info["shared_pd"].number}-compute@developer.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:project-service-account@${local.shared_pd_project}.iam.gserviceaccount.com"
}


# The Cloud Functions Service Agent (Robot) needs to "act as" the compute SA
resource "google_service_account_iam_member" "shared_np_robot_act_as_compute" {
  # Resource: Shared Project's Default Compute SA
  service_account_id = "projects/${local.shared_np_project}/serviceAccounts/${data.google_project.np_service_projects_info["shared_np"].number}-compute@developer.gserviceaccount.com"
  
  role   = "roles/iam.serviceAccountUser"
  
  # Member: The Cloud Functions Robot for the Shared Project
  member = "serviceAccount:service-${data.google_project.np_service_projects_info["shared_np"].number}@gcf-admin-robot.iam.gserviceaccount.com"
}

# Repeat for Prod using the same modular pattern
resource "google_service_account_iam_member" "shared_pd_robot_act_as_compute" {
  service_account_id = "projects/${local.shared_pd_project}/serviceAccounts/${data.google_project.pd_service_projects_info["shared_pd"].number}-compute@developer.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:service-${data.google_project.pd_service_projects_info["shared_pd"].number}@gcf-admin-robot.iam.gserviceaccount.com"
}


# ---------------------------------------------------------
# ROOT CAUSE FIX: Authorize ALL Robots to use the Runtime SA
# ---------------------------------------------------------

locals {
  # The list of robots that must "ActAs" the runtime SA for Gen 2 + Eventarc
  shared_robots = [
    "service-${data.google_project.np_service_projects_info["shared_np"].number}@gcf-admin-robot.iam.gserviceaccount.com",
    "service-${data.google_project.np_service_projects_info["shared_np"].number}@serverless-robot-prod.iam.gserviceaccount.com",
    "service-${data.google_project.np_service_projects_info["shared_np"].number}@gcp-sa-eventarc.iam.gserviceaccount.com"
  ]
}

resource "google_service_account_iam_member" "shared_np_robots_act_as_compute" {
  for_each = toset(local.shared_robots)

  # Resource: The Shared Project's Default Compute SA
  service_account_id = "projects/${local.shared_np_project}/serviceAccounts/${data.google_project.np_service_projects_info["shared_np"].number}-compute@developer.gserviceaccount.com"
  
  role   = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${each.value}"
}

# 1. Grant Cloud Functions Developer to the Cloud Build Service Account
resource "google_project_iam_member" "shared_np_cloudbuild_cf_developer" {
  project = local.shared_np_project
  role    = "roles/cloudfunctions.developer"
  member  = "serviceAccount:${data.google_project.np_service_projects_info["shared_np"].number}@cloudbuild.gserviceaccount.com"
}

# 2. Grant ActAs to the Cloud Build Service Account on the Compute SA
resource "google_service_account_iam_member" "shared_np_cloudbuild_act_as_compute" {
  service_account_id = "projects/${local.shared_np_project}/serviceAccounts/${data.google_project.np_service_projects_info["shared_np"].number}-compute@developer.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${data.google_project.np_service_projects_info["shared_np"].number}@cloudbuild.gserviceaccount.com"
}

# Modular repetition for Production (PD)
resource "google_project_iam_member" "shared_pd_cloudbuild_cf_developer" {
  project = local.shared_pd_project
  role    = "roles/cloudfunctions.developer"
  member  = "serviceAccount:${data.google_project.pd_service_projects_info["shared_pd"].number}@cloudbuild.gserviceaccount.com"
}

resource "google_service_account_iam_member" "shared_pd_cloudbuild_act_as_compute" {
  service_account_id = "projects/${local.shared_pd_project}/serviceAccounts/${data.google_project.pd_service_projects_info["shared_pd"].number}-compute@developer.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${data.google_project.pd_service_projects_info["shared_pd"].number}@cloudbuild.gserviceaccount.com"
}

# Authorize the GCF Robot for Discovery in the Shared Project
resource "google_project_iam_member" "shared_np_gcf_robot_discovery" {
  project = local.shared_np_project
  role    = "roles/cloudfunctions.developer"
  member  = "serviceAccount:service-${data.google_project.np_service_projects_info["shared_np"].number}@gcf-admin-robot.iam.gserviceaccount.com"
}



resource "google_project_iam_audit_config" "shared_np_cf_audit" {
  project = local.shared_np_project
  service = "cloudfunctions.googleapis.com"
  
  audit_log_config {
    log_type = "ADMIN_READ" # This captures the "get" and "list" calls
  }
}
