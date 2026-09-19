module "git_repository" {
  source  = "../../_registry/flux_git_repository"
  context = local.context

  github_repository_full_name = local.push_enabled ? data.github_repository.this[0].full_name : null

  depends_on = [kubectl_manifest.instance]
}
