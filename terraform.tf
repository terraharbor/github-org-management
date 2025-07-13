terraform {
  required_version = ">= 1.10"

  backend "s3" {
    bucket       = "atomp-tf-states"
    key          = "terraharbor-tf-states/github-org-management/terraform.tfstate"
    use_lockfile = true
    encrypt      = true
    region       = "eu-west-1"
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
