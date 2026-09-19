data "http" "github_meta" {
  count = local.push_enabled ? 1 : 0

  url = "https://api.github.com/meta"
}

data "github_repository" "this" {
  count = local.push_enabled ? 1 : 0

  name = var.repository
}
