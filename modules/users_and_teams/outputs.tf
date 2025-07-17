output "organization_owners" {
  description = "Organization owners."
  value       = local.owners
}

output "owner_team_id" {
  description = "ID of the owners team in the organization."
  value       = resource.github_team.owner.id
}

output "default_teams_ids" {
  description = "IDs of the default teams in the organization."
  value = {
    for team_name, team_description in local.default_teams : team_name => resource.github_team.default_team[team_name].id
  }
}
