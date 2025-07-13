resource "github_membership" "owner" {
  for_each = toset(local.owners)

  username = each.key
  role     = "admin"
}

resource "github_membership" "member" {
  for_each = local.users

  username = each.key
  role     = "member"
}
