output "organization_owners" {
  description = "Organization owners."
  value       = local.owners
}

output "default_teams_ids" {
  description = "IDs of the default teams in the organization."
  value = {
    for team_name, team_description in local.default_teams : team_name => github_team.default_team[team_name].id
  }
}
