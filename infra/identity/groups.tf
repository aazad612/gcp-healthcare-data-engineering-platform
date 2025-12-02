resource "googleworkspace_group" "groups" {
  for_each = var.identity_groups

  email       = each.value.email
  name        = each.value.name
  description = each.value.description
}
