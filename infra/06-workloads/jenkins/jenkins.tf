###############################################################
# TERRAFORM + PROVIDER
###############################################################
terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "johneys-tf-states"
    prefix = "jenkins-server"
  }
}

provider "google" {
  region                = "us-central1"
  user_project_override = true
  billing_project       = "johneysadminproject"
}

###############################################################
# READ NETWORKING SHARED VPC INFO (LAYER 03)
###############################################################
data "terraform_remote_state" "net" {
  backend = "gcs"
  config = {
    bucket = "johneys-tf-states"
    prefix = "healthcare-landing-zone/03-networking"
  }
}

locals {
  hub_project = data.terraform_remote_state.net.outputs.host_project_ids["hub"]
  hub_subnet  = data.terraform_remote_state.net.outputs.subnet_ids["hub_main"]
  hub_vpc     = data.terraform_remote_state.net.outputs.vpc_ids["hub"]
}

###############################################################
# RESERVED STATIC IP FOR LOAD BALANCER
###############################################################
# resource "google_compute_global_address" "jenkins_lb_ip" {
#   name    = "jenkins-lb-ip"
#   project = local.hub_project
# }

###############################################################
# FIREWALL RULE
###############################################################
resource "google_compute_firewall" "jenkins_fw" {
  name    = "jenkins-allow-8080"
  project = local.hub_project
  network = local.hub_vpc

  allow {
    protocol = "tcp"
    ports    = ["8080", "22"]
  }

  source_ranges = ["0.0.0.0/0"]

  depends_on = [
    data.terraform_remote_state.net
  ]
}

###############################################################
# JENKINS VM
###############################################################
resource "google_compute_instance" "jenkins" {
  name         = "jenkins-server"
  project      = local.hub_project
  zone         = "us-central1-a"
  machine_type = "n2-standard-4"

  tags = ["jenkins"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 30
    }
  }

  network_interface {
    subnetwork = local.hub_subnet
    # remove this if you want LB-only access
    # access_config {}
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    apt-get update -y
    apt-get install -y fontconfig openjdk-17-jre wget gnupg

    # Install Jenkins signing key
    install -m 0755 -d /etc/apt/keyrings
    wget -O /etc/apt/keyrings/jenkins-keyring.asc \
      https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

    # Add Jenkins repo
    echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
      https://pkg.jenkins.io/debian-stable binary/" \
      > /etc/apt/sources.list.d/jenkins.list

    apt-get update -y
    apt-get install -y jenkins

    systemctl enable jenkins
    systemctl start jenkins
  EOF

  allow_stopping_for_update = true // Required for SA change on running VM

  service_account {
    email  = google_service_account.jenkins_deployer_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  depends_on = [
    google_compute_firewall.jenkins_fw,
    google_service_account.jenkins_deployer_sa
  ]
}

###############################################################
# INSTANCE GROUP (unmanaged)
###############################################################
# resource "google_compute_instance_group" "jenkins_group" {
#   name    = "jenkins-group"
#   project = local.hub_project
#   zone    = "us-central1-a"

#   instances = [
#     google_compute_instance.jenkins.self_link
#   ]

#   named_port {
#     name = "http"
#     port = 8080
#   }

#   depends_on = [
#     google_compute_instance.jenkins
#   ]
# }

###############################################################
# HEALTH CHECK
###############################################################
# resource "google_compute_health_check" "jenkins_hc" {
#   name    = "jenkins-hc"
#   project = local.hub_project

#   http_health_check {
#     port = 8080
#   }

#   depends_on = [
#     google_compute_instance_group.jenkins_group
#   ]
# }

###############################################################
# BACKEND SERVICE
###############################################################
# resource "google_compute_backend_service" "jenkins_backend" {
#   name        = "jenkins-backend"
#   project     = local.hub_project
#   protocol    = "HTTP"
#   port_name   = "http"
#   timeout_sec = 30

#   backend {
#     group = google_compute_instance_group.jenkins_group.self_link
#   }

#   health_checks = [google_compute_health_check.jenkins_hc.self_link]

#   depends_on = [
#     google_compute_health_check.jenkins_hc,
#     google_compute_instance_group.jenkins_group
#   ]
# }

# ###############################################################
# # URL MAP → PROXY → FORWARDING RULE
# ###############################################################
# resource "google_compute_url_map" "jenkins_map" {
#   name            = "jenkins-url-map"
#   project         = local.hub_project
#   default_service = google_compute_backend_service.jenkins_backend.self_link
# }

# resource "google_compute_target_http_proxy" "jenkins_proxy" {
#   name    = "jenkins-http-proxy"
#   project = local.hub_project
#   url_map = google_compute_url_map.jenkins_map.self_link
# }

# resource "google_compute_global_forwarding_rule" "jenkins_fr" {
#   name       = "jenkins-forwarding-rule"
#   project    = local.hub_project
#   ip_address = google_compute_global_address.jenkins_lb_ip.address
#   port_range = "80"
#   target     = google_compute_target_http_proxy.jenkins_proxy.self_link

#   depends_on = [
#     google_compute_target_http_proxy.jenkins_proxy
#   ]
# }

# ###############################################################
# # OUTPUTS
# ###############################################################
# output "jenkins_external_ip" {
#   value = google_compute_global_address.jenkins_lb_ip.address
# }

# output "jenkins_vm_ip" {
#   value = google_compute_instance.jenkins.network_interface[0].access_config[0].nat_ip
# }
