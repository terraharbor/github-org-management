terraform {
  required_version = ">= 1.10"

  backend "azurerm" {
    # This Storage Account and Container must already exist. They were created manually.
    resource_group_name  = "remote-terraform-states-rg"
    storage_account_name = "terraformstates864fc5e1"
    container_name       = "terraharbor-project"
    key                  = "pdg-terraharbor-github-org-management.tfstate"
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~>6"
    }
  }
}

provider "github" {
  owner = var.github_organization
  app_auth {
    id              = var.github_app_id              # or `GITHUB_APP_ID`
    installation_id = var.github_app_installation_id # or `GITHUB_APP_INSTALLATION_ID`
    pem_file        = var.github_app_pem_file        # or `GITHUB_APP_PEM_FILE`
  }
}
