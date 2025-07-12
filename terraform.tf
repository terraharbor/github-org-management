terraform {
  required_version = ">= 1.10"

  backend "s3" {
    bucket       = "atomp-tf-states"
    key          = "terraharbor-tf-states/github-org-management/terraform.tfstate"
    use_lockfile = true
    encrypt      = true
    region       = "eu-west-1"
  }
}
