output "organization" {
  value = data.github_organization.org.orgname
}

output "organization_owners" {
  value = sort([for value in data.github_organization.org.users : value.login if value.role == "ADMIN"])
}

output "organization_members" {
  value = sort([for value in data.github_organization.org.users : value.login if value.role == "MEMBER"])
}

output "organization_repositories" {
  value = sort(data.github_organization.org.repositories)
}
