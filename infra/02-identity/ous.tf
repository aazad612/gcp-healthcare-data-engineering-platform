resource "googleworkspace_org_unit" "main" {
  for_each = var.org_units

  name                 = each.key
  parent_org_unit_path = "/"
  description          = "Managed by Terraform"
}