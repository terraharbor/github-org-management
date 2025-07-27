resource "github_repository" "protected_repository" {
  for_each = local.protected_repositories

  name         = each.key
  description  = each.value.description
  homepage_url = "https://terraharbor.cloud" # TODO Define a proper homepage URL for the project.
  topics       = each.value.topics

  visibility = each.value.visibility

  has_issues      = true
  has_projects    = true
  has_discussions = false
  has_wiki        = false

  allow_merge_commit          = true
  allow_squash_merge          = true
  allow_rebase_merge          = false
  delete_branch_on_merge      = true
  merge_commit_message        = "PR_TITLE"
  merge_commit_title          = "MERGE_MESSAGE"
  squash_merge_commit_message = "BLANK"
  squash_merge_commit_title   = "PR_TITLE"

  auto_init = false # Do not auto-init the repository, as it is already created and protected.

  lifecycle {
    # Prevent the destruction of the protected repositories, because they are critical for this Terraform code.
    prevent_destroy = true
  }
}

resource "github_repository" "repository" {
  for_each = local.github_repositories

  name         = each.key
  description  = each.value.description
  homepage_url = "https://terraharbor.cloud" # TODO Define a proper homepage URL for the project.
  topics       = each.value.topics

  visibility = each.value.visibility

  has_issues      = true
  has_projects    = true
  has_discussions = false
  has_wiki        = false

  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = false
  delete_branch_on_merge = true
  # merge_commit_message        = "PR_TITLE"
  # merge_commit_title          = "MERGE_MESSAGE"
  # squash_merge_commit_message = "BLANK"
  # squash_merge_commit_title   = "PR_TITLE"

  auto_init = true
}

resource "time_sleep" "wait_for_repo_creation" {
  for_each = resource.github_repository.repository

  create_duration = "30s"
}

resource "github_branch_default" "main" {
  for_each = resource.github_repository.repository

  repository = each.value.name
  branch     = "main"
}

resource "github_repository_ruleset" "main_branch_protection_ruleset" {
  for_each = resource.github_repository.repository

  name = "main protection"

  repository  = resource.github_repository.repository[each.key].name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  # Add GitHub Apps that can bypass the ruleset.
  dynamic "bypass_actors" {
    for_each = local.github_apps_automation

    content {
      actor_id    = bypass_actors.value
      actor_type  = "Integration"
      bypass_mode = "always"
    }
  }

  # Add organization teams that can bypass the ruleset.
  dynamic "bypass_actors" {
    for_each = [
      var.owner_team_id,
    ]

    content {
      actor_id    = bypass_actors.value
      actor_type  = "Team"
      bypass_mode = "always"
    }
  }

  rules {
    creation                = true
    update                  = false
    deletion                = true
    required_linear_history = false
    required_signatures     = false

    pull_request {
      dismiss_stale_reviews_on_push     = true
      require_code_owner_review         = true
      require_last_push_approval        = true
      required_approving_review_count   = 1
      required_review_thread_resolution = true
    }
  }
}

# ---

# Addition of teams with default permission to the repositories

resource "github_team_repository" "read" {
  for_each = resource.github_repository.repository

  team_id    = var.default_teams_ids["read"]
  repository = resource.github_repository.repository[each.key].name

  permission = "pull"
}

resource "github_team_repository" "triage" {
  for_each = resource.github_repository.repository

  team_id    = var.default_teams_ids["triage"]
  repository = resource.github_repository.repository[each.key].name

  permission = "triage"
}

resource "github_team_repository" "write" {
  for_each = resource.github_repository.repository

  team_id    = var.default_teams_ids["write"]
  repository = resource.github_repository.repository[each.key].name

  permission = "push"
}

resource "github_team_repository" "maintain" {
  for_each = resource.github_repository.repository

  team_id    = var.default_teams_ids["maintain"]
  repository = resource.github_repository.repository[each.key].name

  permission = "maintain"
}

resource "github_team_repository" "admin" {
  for_each = resource.github_repository.repository

  team_id    = var.default_teams_ids["admin"]
  repository = resource.github_repository.repository[each.key].name

  permission = "admin"
}

# ---

# Addition of the organization secrets to each repository
# The secrets were manually added to the organization in the GitHub UI. They need to have their visibility set to 
# "selected" in order for this resource to work. 

resource "github_actions_organization_secret_repositories" "organization_secrets_permissions" {
  for_each = toset(local.organization_secrets)

  secret_name             = each.value
  selected_repository_ids = [for repo in resource.github_repository.repository : repo.repo_id]
}

# ---

# Creation of default labels for all repositories

resource "github_issue_labels" "default_labels" {
  for_each = resource.github_repository.repository

  repository = resource.github_repository.repository[each.key].name

  dynamic "label" {
    for_each = { for k, v in local.default_labels : k => v if v.description == null }

    content {
      name  = label.value["name"]
      color = label.value["color"]
    }
  }

  dynamic "label" {
    for_each = { for k, v in local.default_labels : k => v if v.description != null }

    content {
      name        = label.value["name"]
      color       = label.value["color"]
      description = label.value["description"]
    }
  }
}

# ---

# Creation of commonly used files
resource "github_repository_file" "license" {
  for_each = resource.github_repository.repository

  depends_on = [resource.time_sleep.wait_for_repo_creation]

  repository          = each.value.name
  branch              = "main"
  file                = "LICENSE.txt"
  content             = file("${path.module}/files/LICENSE.txt")
  commit_message      = "chore: add/edit LICENSE.txt"
  overwrite_on_create = true
  autocreate_branch   = true
}


resource "github_repository_file" "codeowners" {
  for_each = resource.github_repository.repository

  depends_on = [resource.time_sleep.wait_for_repo_creation]

  repository          = each.value.name
  branch              = "main"
  file                = ".github/CODEOWNERS"
  content             = file("${path.module}/files/CODEOWNERS")
  commit_message      = "chore: add/edit CODEOWNERS"
  overwrite_on_create = true
  autocreate_branch   = true
}

# ---

# Creation of the default GitHub Actions workflows

resource "github_repository_file" "commits_checks" {
  for_each = toset([
    for repo, attrib in local.github_repositories : repo if try(attrib.files.github_workflows.commits_checks, true)
  ])

  depends_on = [resource.time_sleep.wait_for_repo_creation]

  repository          = each.value
  branch              = "main"
  file                = ".github/workflows/commits-checks.yaml"
  content             = file("${path.module}/files/workflows/commits-checks.yaml")
  commit_message      = "ci: add/edit commits-checks.yaml"
  overwrite_on_create = true
  autocreate_branch   = true
}

resource "github_repository_file" "pr_issues_project" {
  for_each = toset([
    for repo, attrib in local.github_repositories : repo if try(attrib.files.github_workflows.pr_issues_project, true)
  ])

  depends_on = [resource.time_sleep.wait_for_repo_creation]

  repository          = each.value
  branch              = "main"
  file                = ".github/workflows/pr-issues-project.yaml"
  content             = file("${path.module}/files/workflows/pr-issues-project.yaml")
  commit_message      = "ci: add/edit pr-issues-project.yaml"
  overwrite_on_create = true
  autocreate_branch   = true
}

resource "github_repository_file" "release_please" {
  for_each = toset([
    for repo, attrib in local.github_repositories : repo if try(attrib.files.github_workflows.release_please, true)
  ])

  depends_on = [resource.time_sleep.wait_for_repo_creation]

  repository          = each.value
  branch              = "main"
  file                = ".github/workflows/release-please.yaml"
  content             = file("${path.module}/files/workflows/release-please.yaml")
  commit_message      = "ci: add/edit release-please.yaml"
  overwrite_on_create = true
  autocreate_branch   = true
}

resource "github_repository_file" "docker_build" {
  for_each = toset([
    for repo, attrib in local.github_repositories : repo if try(attrib.files.github_workflows.docker_build, true)
  ])

  depends_on = [resource.time_sleep.wait_for_repo_creation]

  repository          = each.value
  branch              = "main"
  file                = ".github/workflows/docker-build.yaml"
  content             = file("${path.module}/files/workflows/docker-build.yaml")
  commit_message      = "ci: add/edit docker-build.yaml"
  overwrite_on_create = true
  autocreate_branch   = true
}

# ---

# Creation of the Renovate configuration file

resource "github_repository_file" "renovate_config" {
  for_each = {
    for repo, attrib in local.github_repositories : repo => try(attrib.files.renovate_patches, "{}") if try(attrib.files.renovate, true)
  }

  depends_on = [resource.time_sleep.wait_for_repo_creation]

  repository = each.key
  branch     = "main"
  file       = ".renovaterc.json"
  content = jsonencode(
    merge(
      jsondecode("{}"),
      jsondecode(each.value)
    )
  )
  commit_message      = "chore: add/edit .renovaterc.json"
  overwrite_on_create = true
  autocreate_branch   = true
}

# ---

# Creation of the Release Please manifest and configuration files

resource "github_repository_file" "release_please_manifest" {
  for_each = {
    for repo, attrib in local.github_repositories : repo => try(attrib.files.release_please_patches, "{}") if try(attrib.files.release_please, true)
  }

  depends_on = [resource.time_sleep.wait_for_repo_creation]

  repository          = each.key
  branch              = "main"
  file                = ".release-please-manifest.json"
  content             = "{}"
  commit_message      = "chore: add/edit release-please-manifest.json"
  overwrite_on_create = true
  autocreate_branch   = true

  lifecycle {
    ignore_changes = all # Simply create the file for the bootstrapping, then it will be managed by Release Please.
  }
}

resource "github_repository_file" "release_please_config" {
  for_each = {
    for repo, attrib in local.github_repositories : repo => try(attrib.files.release_please_patches, "{}") if try(attrib.files.release_please, true)
  }

  depends_on = [resource.time_sleep.wait_for_repo_creation]

  repository = each.key
  branch     = "main"
  file       = "release-please-config.json"
  content = jsonencode(
    merge(
      jsondecode(file("${path.module}/files/release-please-config.json")),
      jsondecode(each.value)
    )
  )
  commit_message      = "chore: add/edit release-please-config.json"
  overwrite_on_create = true
  autocreate_branch   = true
}

# ---
