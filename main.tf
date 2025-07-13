data "github_organization" "org" {
  name = var.github_organization
}

module "users_and_teams" {
  source = "./modules/users_and_teams"
}
