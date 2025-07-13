variable "github_organization" {
  description = "Name of the GitHub organization."
  type        = string
  nullable    = false
  default     = "terraharbor"
}

variable "github_app_id" {
  description = "ID of the GitHub application used for authentication of the GitHub Terraform provider."
  type        = string
  nullable    = false
  ephemeral   = true
}

variable "github_app_installation_id" {
  description = "Installation ID of the GitHub application used for authentication of the GitHub Terraform provider."
  type        = string
  nullable    = false
  ephemeral   = true
}

variable "github_app_pem_file" {
  description = <<-EOT
    Content of the PEM file of the GitHub application used for authentication of the GitHub Terraform provider.

    Needs to be in the format:

    -----BEGIN RSA PRIVATE KEY-----
    ...
    -----END RSA PRIVATE KEY-----
  EOT
  type        = string
  nullable    = false
  sensitive   = true
  ephemeral   = true
}
