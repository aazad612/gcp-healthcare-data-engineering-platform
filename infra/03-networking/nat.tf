
# resource "google_compute_router" "hub_router_nat" {
#   name    = "hub-${var.subnets["hub_main"].name}-router"
#   network = google_compute_network.hub_vpc.name
#   project = google_project.hub_host.project_id
#   # Use the region of the subnet
#   region  = var.subnets["hub_main"].region

#   # Ensure the router is created after the network/project are ready
#   depends_on = [google_project_service.hub_apis]
# }

# ## ---------------------------
# ## 2. CLOUD NAT GATEWAY
# ## ---------------------------
# # The NAT gateway translates the private IPs of non-external-IP VMs
# # in the subnet to public IPs for outbound traffic.

# resource "google_compute_router_nat" "hub_nat_gateway" {
#   name                             = "hub-${var.subnets["hub_main"].name}-nat"
#   router                           = google_compute_router.hub_router_nat.name
#   project                          = google_project.hub_host.project_id
#   region                           = google_compute_router.hub_router_nat.region
  
#   # Allocate IPs automatically (Google manages the public IPs for you)
#   nat_ip_allocate_option           = "AUTO_ONLY"
  
#   # Specify which subnets in the VPC will use this NAT.
#   # We specify the exact subnetwork where Jenkins lives (hub_subnet).
#   source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

#   # Define the specific subnet to enable NAT for
#   subnetwork {
#     name = google_compute_subnetwork.hub_subnet.self_link
    
#     # Enable NAT for all primary and secondary IP ranges of the subnet
#     source_ip_ranges_to_nat = ["ALL_IP_RANGES"] 
#   }

#   log_config {
#     enable = true
#     filter = "ERRORS_ONLY"
#   }
  
#   # Ensure NAT is created after the router is ready
#   depends_on = [google_compute_router.hub_router_nat]
# }

# ## ---------------------------
# ## 3. FIREWALL RULE (Crucial for allowing egress)
# ## ---------------------------
# # Although your Jenkins VM might not have an external IP, you still need an
# # Egress firewall rule allowing traffic out to the internet (0.0.0.0/0).
# # The NAT gateway will handle the translation.

# resource "google_compute_firewall" "allow_egress_from_hub" {
#   name    = "allow-hub-egress-to-internet"
#   project = google_project.hub_host.project_id
#   network = google_compute_network.hub_vpc.self_link

#   direction = "EGRESS"
#   # Target tags can be applied to your Jenkins VM if you want to restrict this rule
#   # target_tags = ["jenkins-vm"] 

#   allow {
#     protocol = "all"
#   }

#   # Allow all traffic out to the internet
#   destination_ranges = ["0.0.0.0/0"]
# }