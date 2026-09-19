resource "tls_private_key" "push" {
  count = local.push_enabled ? 1 : 0

  algorithm = "ED25519"
}

resource "github_repository_deploy_key" "push" {
  count = local.push_enabled ? 1 : 0

  repository = data.github_repository.this[0].name
  title      = "flux-image-automation-${local.environment}"
  key        = tls_private_key.push[0].public_key_openssh
  read_only  = false
}

resource "kubernetes_secret_v1" "push" {
  count = local.push_enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = module.git_repository.name
  }

  data = {
    identity       = tls_private_key.push[0].private_key_openssh
    "identity.pub" = tls_private_key.push[0].public_key_openssh
    known_hosts    = local.known_hosts
  }

  lifecycle {
    precondition {
      condition     = length(local.github_host_keys) == 1
      error_message = "Expected exactly one Ed25519 host key from api.github.com/meta, got ${length(local.github_host_keys)}."
    }
  }
}
