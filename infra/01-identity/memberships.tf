// memberships.tf
// Group memberships: link users to groups with roles.

resource "googleworkspace_group_member" "memberships" {
  for_each = var.group_memberships

  # group_id can be the group's email or unique ID; email is fine here.
  group_id = googleworkspace_group.groups[each.value.group_key].email

  # Member's email address (user)
  email = var.identity_users[each.value.user_key].primary_email

  # One of: "OWNER", "MANAGER", "MEMBER"
  role  = each.value.role
}
