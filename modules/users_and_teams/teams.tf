# Owners team.
resource "github_team" "owner" {
  name        = "owner"
  description = "Organization owners."
  privacy     = "closed"
}

# Memberships for the owners team.
resource "github_team_members" "owner" {
  team_id = resource.github_team.owner.id

  dynamic "members" {
    for_each = local.owners

    content {
      username = members.value
      role     = "maintainer"
    }
  }
}

# ---

# Default organization teams that all users belong to in order to manage the global permissions.
# These teams are then added to the repositories as needed and with the appropriate permissions by the 
# `repositories` submodule.
resource "github_team" "default_team" {
  for_each = local.default_teams

  name        = each.key
  description = each.value
  privacy     = "closed"
}

# Memberships for the default organization teams.
resource "github_team_members" "default_team" {
  for_each = toset(distinct(flatten([for user, teams in local.users : teams])))

  team_id = resource.github_team.default_team[each.key].id

  # Dumb dynamic block to create the dynamic block when the for_each above returns [], otherwise Terraform will throw 
  # an error. The other dynamic block below is the one that matters and will be created only if there are users with 
  # teams in the organization.
  dynamic "members" {
    for_each = length(flatten([for user, teams in local.users : teams])) == 0 ? ["toto"] : []

    content {
      username = members.value
      role     = "member"
    }
  }

  dynamic "members" {
    for_each = [for k, v in local.users : k if contains(v, each.key)]

    content {
      username = members.value
      role     = "member"
    }
  }
}

# ---

# Extra organization teams.
resource "github_team" "team" {
  for_each = local.teams

  name        = each.key
  description = each.value
  privacy     = "closed"
}

# Memberships for the extra organization teams.
resource "github_team_members" "team" {
  for_each = local.teams != {} ? toset(distinct(flatten([for user, teams in local.users : teams]))) : []

  team_id = resource.github_team.team[each.key].id

  # Dumb dynamic block to create the dynamic block when the for_each above returns [], otherwise Terraform will throw 
  # an error. The other dynamic block below is the one that matters and will be created only if there are users with 
  # teams in the organization.
  dynamic "members" {
    for_each = length(flatten([for user, teams in local.users : teams])) == 0 ? ["toto"] : []

    content {
      username = members.value
      role     = "member"
    }
  }

  dynamic "members" {
    for_each = [for k, v in local.users : k if contains(v, each.key)]

    content {
      username = members.value
      role     = "member"
    }
  }
}
