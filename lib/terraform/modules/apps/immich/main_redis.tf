resource "kubectl_manifest" "redis" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "dragonflydb.io/v1alpha1"
    kind       = "Dragonfly"

    metadata = {
      namespace = local.namespace
      name      = "${local.name}-cache"
    }

    spec = {
      replicas = 2

      args = [
        # SEE: https://github.com/immich-app/immich/issues/2542#issuecomment-2564396901
        "--default_lua_flags=allow-undeclared-keys"
      ]
    }
  })
}
