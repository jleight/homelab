# nginx renders this into the Authorization header it sends upstream.
resource "kubernetes_secret_v1" "github_proxy" {
  metadata {
    namespace = module.namespace.name
    name      = "github-proxy"
  }

  data = {
    GITHUB_PROXY_TOKEN = data.onepassword_item.github_proxy_token.credential
  }
}

# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "github_proxy_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "github-proxy-subst"
  }

  data = {
    gateway_parent_refs = jsonencode(var.github_proxy.gateway_refs)
    domain              = local.github_proxy_domain
    token_secret        = kubernetes_secret_v1.github_proxy.metadata[0].name
    token_checksum      = "sha256:${sha256(jsonencode(kubernetes_secret_v1.github_proxy.data))}"
  }
}
