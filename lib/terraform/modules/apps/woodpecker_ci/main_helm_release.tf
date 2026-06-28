resource "helm_release" "this" {
  count = local.enabled ? 1 : 0

  namespace  = local.namespace
  name       = local.name
  repository = var.woodpecker_ci.repository
  chart      = var.woodpecker_ci.chart
  version    = var.woodpecker_ci.version

  set = [
    for k, v in {
      # Server: state lives in Postgres, so no server PV (and no sqlite on
      # replicated storage).
      "server.persistentVolume.enabled" = false

      "server.env.WOODPECKER_HOST"            = "https://${local.hostname}"
      "server.env.WOODPECKER_OPEN"            = "false"
      "server.env.WOODPECKER_ADMIN"           = var.forgejo_admin_username
      "server.env.WOODPECKER_DATABASE_DRIVER" = "postgres"
      "server.env.WOODPECKER_FORGEJO"         = "true"
      "server.env.WOODPECKER_FORGEJO_URL"     = var.forgejo_url

      "server.extraSecretNamesForEnvFrom[0]" = local.forge_secret_name

      # Agent: Kubernetes backend, each step runs as its own pod. The throwaway
      # per-pipeline workspace uses non-replicated storage (RWX off) so it does
      # not spin up a Longhorn share-manager per build.
      "agent.replicaCount"        = 1
      "agent.persistence.enabled" = false

      # Stateless agent: with an empty config-file path the agent does not persist
      # its assigned ID and unregisters itself on shutdown, so restarts don't leave
      # stale agent records behind (no PVC/ConfigMap needed for the ID).
      "agent.env.WOODPECKER_AGENT_CONFIG_FILE" = ""

      # The chart defaults the agent's gRPC target to "woodpecker-server:9000",
      # which assumes a release named "woodpecker"; ours is "woodpecker-ci", so
      # point it at the actual server service.
      "agent.env.WOODPECKER_SERVER" = "${local.name}-server:9000"

      "agent.env.WOODPECKER_BACKEND"                   = "kubernetes"
      "agent.env.WOODPECKER_BACKEND_K8S_NAMESPACE"     = local.namespace
      "agent.env.WOODPECKER_BACKEND_K8S_STORAGE_CLASS" = var.workspace_storage_class
      "agent.env.WOODPECKER_BACKEND_K8S_STORAGE_RWX"   = "false"
      "agent.env.WOODPECKER_BACKEND_K8S_VOLUME_SIZE"   = "2G"

      # Allow steps to mount existing k8s secrets via backend_options (e.g. the
      # build step mounting the registry dockerconfig). Off by default; safe here
      # since this is a single-tenant instance running only our own repos.
      "agent.env.WOODPECKER_BACKEND_K8S_ALLOW_NATIVE_SECRETS" = "true"

      # Allow steps to set serviceAccountName via backend_options so CD steps can
      # run as the per-app deployer ServiceAccount (scoped patch rights in the
      # app's namespace). Disabled by default since v3.16.0 for security; safe
      # here since this is a single-tenant instance running only our own repos.
      "agent.env.WOODPECKER_BACKEND_K8S_SERVICE_ACCOUNT_NAME_ALLOW_FROM_STEP" = "true"

      # Attach the Forgejo registry secret as an imagePullSecret on every step pod
      # so pipelines can use private images (e.g. their own pushed images) without
      # the UI "registries" feature (which has no Terraform support).
      "agent.env.WOODPECKER_BACKEND_K8S_PULL_SECRET_NAMES" = local.registry_secret_name
    } : { name = k, value = v }
  ]

  depends_on = [
    kubernetes_secret_v1.forge
  ]
}
