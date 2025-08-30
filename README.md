# github-org-management

This repository contains the Terraform code to manage this GitHub organization, its members, teams, and repositories.

It also contains the configuration files for the GitHub Actions workflows that automate the running of the Terraform code.

Below you will find a few notes that should answer most of your questions or guide you to ask more questions to the proper team members:

- The submodule `modules/users_and_teams` contains the code to manage the members and teams of the organization. All the users and teams of the organization are defined in this module.
- The submodule `modules/repositories` contains the code to manage the repositories of the organization. All the repositories of the organization are defined in this module.
- This repository itself is not created or destroyed by the Terraform code. However, its configuration is managed by the Terraform code (e.g., branch protection rules, team permissions, default files).
- The submodule `modules/repositories` is also responsible for adding default labels, branch protection rules, and other repository settings. It also adds the necessary files to each repository (e.g., LICENSE, CODEOWNERS, a few standard GitHub actions).
- The Terraform state for this code is stored in an Azure Storage Account of the Azure for Students subscription owned by [@lentidas](https://github.com/lentidas).
- This Terraform code authenticates against the GitHub API using a GitHub App owned by the organization and that was created specifically for this purpose. Owners of the organization may check this app's permissions and settings in the GitHub UI.
