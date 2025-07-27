locals {
  # Organization owners.
  owners = [
    "lentidas", # Gonçalo Heleno (goncalocheleno@atomp.eu)
  ]

  # Default teams in decrescent order of permissions.
  default_teams = {
    admin    = "Repository administrators."
    maintain = "Write permissions plus manage issues, pull requests and some repository settings."
    write    = "Triage permissions plus read, clone and push to repositories."
    triage   = "Read permissions plus manage issues and pull requests."
    read     = "Read and clone repositories. Open and comment on issues and pull requests."
  }

  # Extra teams to create.
  teams = {
    # <team_name> = <team_description>
  }

  # Members of the organization and their respective teams.
  users = {
    # <username> = ["<team_name>", ...]

    # Group members go in the admin team.
    "Anthony-Christen" = ["admin"], # Anthony Christen
    "badisnt"          = ["admin"], # Badis Machraoui
    "fabricechapuis"   = ["admin"], # Fabrice Chapuis
    "Svelva"           = ["admin"], # Sven Ferreira Silva

    # Professors and assistants go in the read team.
    "fmhanna" = ["read"], # Fouad Hanna
    "Ga-3tan" = ["read"], # Gaétan Zwick
    # "GeraudSilvestri" = ["read"], # Géraud Silvestri
    # "Rostand"         = ["read"], # Rostand Mitouassiwou
  }
}
