locals {

  github_workflows_disabled = {
    commits_checks    = false
    pr_issues_project = false
    release_please    = false
    docker_build      = false
  }

  # Structure for the repositories' definitions:
  #
  # repository_name = {
  #   description = "A phrase describing the repository" # required
  #   topics      = ["topic1", "topic2", "topic3"] # required
  #   visibility  = "public/private" # required
  #   teams       = ["team1", "team2", "team3"] # TODO The teams variable is not yet implemented on these resources.
  #   files = {
  #     # Whether to create the GitHub Actions workflows, defaults to false.
  #     github_workflows = true/false
  #     # Whether to create the Release Please config, defaults to true.
  #     release_please   = true/false
  #     # The Release Please patches to override the default configurations, defaults to "{}".
  #     release_please_patches = "string in raw JSON format"
  #   }
  # }
  #

  protected_repositories = {
    github-org-management = {
      description = "Repository containing the Terraform code to manage this GitHub organization"
      topics      = ["terraharbor", "terraform", "github"]
      visibility  = "public"
      files = {
        github_workflows = local.github_workflows_disabled
        release_please   = false
        renovate         = false
      }
    },
  }

  generic_repositories = {
    ".github" = {
      description = "Point of entry for the TerraHarbor organization"
      topics      = ["terraharbor", "github"]
      visibility  = "public"
      files = {
        github_workflows = local.github_workflows_disabled
        release_please   = false
        renovate         = false
      }
    },
    project-management = {
      description = "Repository for the general documentation and project management of the TerraHarbor organization"
      topics      = ["terraharbor", "project-management"]
      visibility  = "public"
      files = {
        github_workflows = local.github_workflows_disabled
        release_please   = false
        renovate         = false
      }
    },
    github-actions-workflows = {
      description = "GitHub Actions workflows for the TerraHarbor repositories"
      topics      = ["terraharbor", "github-actions"]
      visibility  = "public"
      files = {
        # Disable the creation of the GitHub Actions workflows for this repository, because it's the one that contains 
        # the workflows that are called by the other repositories.
        github_workflows = local.github_workflows_disabled
      }
    },
    application = {
      description = "Main application repository for the TerraHarbor project"
      topics      = ["terraharbor", "terraform-backend"]
      visibility  = "public"
    },
    frontend = {
      description = "Frontend of the TerraHarbor application written in React"
      topics      = ["terraharbor", "terraform-backend", "react", "docker"]
      visibility  = "public"
    },
    backend = {
      description = "Backend of the TerraHarbor application written in Python and using FastAPI"
      topics      = ["terraharbor", "terraform-backend", "python", "fastapi", "docker"]
      visibility  = "public"
    },
    website = {
      description = "Website repository for the TerraHarbor project"
      topics      = ["terraharbor", "website", "github-pages"]
      visibility  = "public"
      files = {
        github_workflows = {
          docker_build = false
        }
      }
    },
    infrastructure = {
      description = "Infrastructure as Code repository for the TerraHarbor project"
      topics      = ["terraharbor", "infrastructure", "iac", "terraform", "ansible", "docker-compose"]
      visibility  = "public"
      files = {
        github_workflows = {
          docker_build = false
        }
      }
    }
  }

  # Merge all the repositories into a single map.
  github_repositories = merge(local.generic_repositories)

  github_apps_automation = [
    1596572, # terraharbor-administrator
  ]

  organization_secrets = [
    "TERRAHARBOR_MAINTAINER_APP_ID",
    "TERRAHARBOR_MAINTAINER_INSTALLATION_ID",
    "TERRAHARBOR_MAINTAINER_PRIVATE_KEY",
    "TERRAHARBOR_RELEASER_APP_ID",
    "TERRAHARBOR_RELEASER_INSTALLATION_ID",
    "TERRAHARBOR_RELEASER_PRIVATE_KEY",
    "TERRAHARBOR_RENOVATOR_APP_ID",
    "TERRAHARBOR_RENOVATOR_INSTALLATION_ID",
    "TERRAHARBOR_RENOVATOR_PRIVATE_KEY"
  ]

  # Default sane labels for all repositories
  # Ref: https://seantrane.com/posts/logical-colorful-github-labels-18230/
  # Adapted from: https://github.com/seantrane/github-label-presets/blob/914a3a8fa38c84092e189888d06dd78392b061f6/labels.json
  default_labels = {
    # Standard
    breaking = {
      name        = "breaking"
      color       = "d73a4a"
      description = "Changes that break backward compatibility"
    }
    good_first_issue = {
      name        = "good first issue"
      color       = "7057ff"
      description = "Good for newcomers"
    }
    help = {
      name        = "help"
      color       = "0e8a16"
      description = "Help is needed"
    }
    renovate = {
      name        = "renovate"
      color       = "e6e6e6"
      description = null
    }
    autorelease_pending = {
      name        = "autorelease: pending"
      color       = "a6a6a6"
      description = null
    }
    autorelease_tagged = {
      name        = "autorelease: tagged"
      color       = "a6a6a6"
      description = null
    }

    # Effort required in increasing Fibonacci sequence
    effort_1 = {
      name        = "effort: 1"
      color       = "91ca55"
      description = null
    }
    effort_2 = {
      name        = "effort: 2"
      color       = "c2e2a2"
      description = null
    }
    effort_3 = {
      name        = "effort: 3"
      color       = "e9f4dc"
      description = null
    }
    effort_5 = {
      name        = "effort: 5"
      color       = "fef6d7"
      description = null
    }
    effort_8 = {
      name        = "effort: 8"
      color       = "fef2c0"
      description = null
    }
    effort_13 = {
      name        = "effort: 13"
      color       = "fbca04"
      description = null
    }

    # Priority
    priority_now = {
      name        = "priority: now"
      color       = "d73a4a"
      description = null
    }
    priority_soon = {
      name        = "priority: soon"
      color       = "ffb8c6"
      description = null
    }
    priority_2day = {
      name        = "priority: later"
      color       = "fbca04"
      description = null
    }

    # State
    state_approved = {
      name        = "state: approved"
      color       = "91ca55"
      description = "Approved to proceed"
    }
    state_blocked = {
      name        = "state: blocked"
      color       = "d73a4a"
      description = "Something is blocking action"
    }
    state_pending = {
      name        = "state: pending"
      color       = "fbca04"
      description = "Pending requirements, dependencies, data, or more information"
    }
    state_inactive = {
      name        = "state: inactive"
      color       = "e6e6e6"
      description = "No action needed or possible (the issue is fixed, addressed elsewhere, or out of scope)"
    }

    # Type
    type_bug = {
      name        = "type: bug"
      color       = "d73a4a"
      description = "Something isn't working"
    }
    type_chore = {
      name        = "type: chore"
      color       = "fef2c0"
      description = "Converting measurements, reorganizing folder structure, and less impactful tasks"
    }
    type_discussion = {
      name        = "type: discussion"
      color       = "d4c5f9"
      description = "Questions, proposals and info that requires discussion"
    }
    type_docs = {
      name        = "type: docs"
      color       = "fef2c0"
      description = "Related to documentation and information"
    }
    type_feature = {
      name        = "type: feature"
      color       = "5ebeff"
      description = "Brand new functionality, features, pages, workflows, etc."
    }
    type_fix = {
      name        = "type: fix"
      color       = "91ca55"
      description = "Iterations on existing features or infrastructure"
    }
    type_security = {
      name        = "type: security"
      color       = "d73a4a"
      description = "Something is vulnerable or not secure"
    }
    type_testing = {
      name        = "type: testing"
      color       = "fbca04"
      description = "Related to testing and quality assurance"
    }

    # Work required
    # Based on the Cynefin framework - https://en.wikipedia.org/wiki/Cynefin_framework
    work_chaotic = {
      name        = "work: chaotic"
      color       = "fbca04"
      description = "The situation is chaotic, novel practices used"
    }
    work_complex = {
      name        = "work: complex"
      color       = "d4c5f9"
      description = "The situation is complex, emergent practices used"
    }
    work_complicated = {
      name        = "work: complicated"
      color       = "ffb8c6"
      description = "The situation is complicated, good practices used"
    }
    work_obvious = {
      name        = "work: obvious"
      color       = "91ca55"
      description = "The situation is obvious, best practices used"
    }
  }
}
