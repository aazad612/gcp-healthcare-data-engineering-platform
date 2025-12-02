# Non-sensitive identity configuration.
# Passwords live in sensitive.auto.tfvars (gitignored).

cloud_identity_customer_id = "C012345678"        # replace with your real customer ID
admin_impersonation_email  = "aazads@aazads.us"  # your Cloud Identity super admin

identity_users = {
  ava = {
    primary_email  = "ava.khurana@aazads.us"
    given_name     = "Ava"
    family_name    = "Khurana"
    recovery_email = "ava.recovery@aazads.us"
    org_unit_path  = "/Engineering"
  }

  miguel = {
    primary_email  = "miguel.santiago@aazads.us"
    given_name     = "Miguel"
    family_name    = "Santiago"
    recovery_email = "miguel.recovery@aazads.us"
    org_unit_path  = "/Engineering"
  }

  priya = {
    primary_email  = "priya.deshmukh@aazads.us"
    given_name     = "Priya"
    family_name    = "Deshmukh"
    recovery_email = "priya.recovery@aazads.us"
    org_unit_path  = "/Analytics"
  }

  ethan = {
    primary_email  = "ethan.brooks@aazads.us"
    given_name     = "Ethan"
    family_name    = "Brooks"
    recovery_email = "ethan.recovery@aazads.us"
    org_unit_path  = "/Networking"
  }

  sarah = {
    primary_email  = "sarah.whmore@aazads.us"
    given_name     = "Sarah"
    family_name    = "Whitmore"
    recovery_email = "sarah.recovery@aazads.us"
    org_unit_path  = "/ML"
  }

  daniel = {
    primary_email  = "daniel.osei@aazads.us"
    given_name     = "Daniel"
    family_name    = "Osei"
    recovery_email = "daniel.recovery@aazads.us"
    org_unit_path  = "/Data-Governance"
  }
}

identity_groups = {
  cloud_platform_admins = {
    email       = "cloud-platform-admins@aazads.us"
    name        = "Cloud Platform Admins"
    description = "Admins for GCP organization, projects, and core platform."
  }

  netops_admins = {
    email       = "netops-admins@aazads.us"
    name        = "Network Operations Admins"
    description = "Admins for shared VPCs, firewalls, and connectivity."
  }

  data_engineering_admins = {
    email       = "data-engineering-admins@aazads.us"
    name        = "Data Engineering Admins"
    description = "Admins for data engineering platforms and pipelines."
  }

  clinical_analytics_readers = {
    email       = "clinical-analytics-readers@aazads.us"
    name        = "Clinical Analytics Readers"
    description = "Read-only access to approved clinical analytics datasets."
  }

  ml_platform_admins = {
    email       = "ml-platform-admins@aazads.us"
    name        = "ML Platform Admins"
    description = "Admins for ML platforms, notebooks, and training workloads."
  }

  data_governance_stewards = {
    email       = "data-governance-stewards@aazads.us"
    name        = "Data Governance Stewards"
    description = "Owners and stewards for data governance and catalog."
  }
}

group_memberships = {
  ava_platform_admin = {
    user_key  = "ava"
    group_key = "cloud_platform_admins"
    role      = "OWNER"
  }

  ethan_netops_admin = {
    user_key  = "ethan"
    group_key = "netops_admins"
    role      = "MANAGER"
  }

  miguel_data_eng_admin = {
    user_key  = "miguel"
    group_key = "data_engineering_admins"
    role      = "MANAGER"
  }

  priya_clinical_reader = {
    user_key  = "priya"
    group_key = "clinical_analytics_readers"
    role      = "MEMBER"
  }

  sarah_ml_platform_admin = {
    user_key  = "sarah"
    group_key = "ml_platform_admins"
    role      = "MANAGER"
  }

  daniel_data_governance_steward = {
    user_key  = "daniel"
    group_key = "data_governance_stewards"
    role      = "OWNER"
  }
}
