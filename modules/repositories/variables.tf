variable "organization_owners" {
  description = "Usernames of the organization owners. Corresponds to the output of the `users_and_teams` submodule."
  type        = list(string)
}

variable "owner_team_id" {
  description = "ID of the owners team in the organization. Corresponds to the output of the `users_and_teams` submodule."
  type        = number
}

variable "default_teams_ids" {
  description = "IDs of the default teams in the organization. Corresponds to the output of the `users_and_teams` submodule."
  type        = map(string)
}
