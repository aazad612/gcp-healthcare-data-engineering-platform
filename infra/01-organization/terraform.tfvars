# 1. The Service Account (Must be 'Organization Admin' & 'Billing Account Admin')
impersonate_service_account = "johneysadmin@johneysadminproject.iam.gserviceaccount.com"

# 2. Your Organization ID
org_id = "9139207439"

# 3. Folder Logical Names (Do not change keys, only values if needed)
top_level_folders = {
  networking          = "fd-networking"
  shared_services     = "fd-shared-services"
  healthcare_platform = "fd-healthcare-platform"
  business_units      = "fd-business-units"
  data_governance     = "fd-data-governance"
  sandboxes           = "fd-sandboxes"
  research            = "fd-research"
}

# 4. Organization Level Permissions
org_iam_members = [
  {
    role   = "roles/resourcemanager.organizationAdmin"
    member = "group:cloud-platform-admins@aazads.us"
  },
  {
    role   = "roles/resourcemanager.organizationViewer"
    member = "group:cloud-platform-admins@aazads.us"
  }
]

# 5. Folder Level Permissions (Mapped to your real groups)
folder_iam_members = [
  # NetOps owns Networking
  {
    folder_key = "networking"
    role       = "roles/resourcemanager.folderAdmin"
    member     = "group:netops-admins@aazads.us"
  },
  # Data Engineering owns Healthcare Platform
  {
    folder_key = "healthcare_platform"
    role       = "roles/resourcemanager.folderAdmin"
    member     = "group:data-engineering-admins@aazads.us"
  },
  # Data Stewards own Data Governance
  {
    folder_key = "data_governance"
    role       = "roles/resourcemanager.folderAdmin"
    member     = "group:data-governance-stewards@aazads.us"
  },
  # ML Admins own Sandboxes (common pattern for experimentation)
  {
    folder_key = "sandboxes"
    role       = "roles/resourcemanager.folderAdmin"
    member     = "group:ml-platform-admins@aazads.us"
  }
]

# 6. Billing Account Permissions
billing_iam_members = [
  {
    billing_account_id = "01D9F1-90D8BC-2AE0A2" # 
    role               = "roles/billing.admin"
    member             = "group:cloud-platform-admins@aazads.us"
  }
]

# 7. Org Policies
org_boolean_policies = {
  disable_serial_port = {
    constraint = "compute.disableSerialPortAccess"
    enforced   = true
  }
  skip_default_network = {
    constraint = "compute.skipDefaultNetworkCreation"
    enforced   = true
  }
}

org_list_policies = {
  allowed_locations = {
    constraint     = "gcp.resourceLocations"
    deny_all       = false
    allowed_values = ["in:us-locations"]
    denied_values  = []
  }
}