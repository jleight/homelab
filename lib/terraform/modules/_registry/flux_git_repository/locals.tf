locals {
  name      = "homelab-push"
  namespace = "flux-system"
  branch    = "main"

  create = local.enabled && var.github_repository_full_name != null
  url    = local.create ? "ssh://git@github.com/${var.github_repository_full_name}.git" : null
}
