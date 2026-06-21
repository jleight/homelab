# Sensitive server configuration, surfaced to the Woodpecker server as
# environment variables via server.extraSecretNamesForEnvFrom. The keys are
# valid env var names so the chart's envFrom picks them up verbatim.
resource "kubernetes_secret_v1" "forge" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-forge"
  }

  data = {
    WOODPECKER_FORGEJO_CLIENT      = local.oauth_client_id
    WOODPECKER_FORGEJO_SECRET      = local.oauth_client_secret
    WOODPECKER_DATABASE_DATASOURCE = local.postgres_datasource
  }
}

# dockerconfigjson for pushing images to the Forgejo registry from build steps.
# Mounted into the build step pod by the pipeline (see README).
resource "kubernetes_secret_v1" "registry" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-registry"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        (local.registry_host) = {
          username = local.ci_username
          password = local.ci_password
          auth     = base64encode("${local.ci_username}:${local.ci_password}")
        }
      }
    })
  }
}
