data "github_organization" "org" {
  name = var.github_organization
}

module "users_and_teams" {
  source = "./modules/users_and_teams"
}


module "repositories" {
  source = "./modules/repositories"

  organization_owners = module.users_and_teams.organization_owners
  owner_team_id       = module.users_and_teams.owner_team_id
  default_teams_ids   = module.users_and_teams.default_teams_ids
}
