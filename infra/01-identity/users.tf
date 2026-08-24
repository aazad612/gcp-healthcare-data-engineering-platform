resource "googleworkspace_user" "users" {
  for_each = var.identity_users

  primary_email = each.value.primary_email

  name {
    given_name  = each.value.given_name
    family_name = each.value.family_name
  }

  password                      = var.identity_passwords[each.key]
  change_password_at_next_login = true
  recovery_email                = each.value.recovery_email
  org_unit_path                 = each.value.org_unit_path

  # Critical: Wait for OUs to exist before creating users in them
  depends_on = [googleworkspace_org_unit.main]
}