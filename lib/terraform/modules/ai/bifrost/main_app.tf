module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = var.namespace

  image         = var.bifrost.image
  image_version = var.bifrost.version

  port         = 8080
  service_port = 8080

  subdomain = var.bifrost.subdomain
  path      = var.bifrost.path

  gateway_refs   = var.gateway_refs
  gateway_domain = var.gateway_domain

  env_from_secrets = [local.secret_name]

  pod_annotations = {
    "checksum/config" = sha256(kubernetes_config_map_v1.this[0].data["config.json"])
  }

  # /app/data is Bifrost's app directory. With both stores in Postgres nothing
  # in it needs to outlive the pod, so it is an emptyDir with config.json
  # layered on top.
  volumes_empty_dir = ["data"]

  volumes_from_config_maps = {
    config = kubernetes_config_map_v1.this[0].metadata[0].name
  }

  volume_mounts = [
    {
      name       = "data"
      mount_path = "/app/data"
    },
    {
      name       = "config"
      mount_path = "/app/data/config.json"
      sub_path   = "config.json"
      read_only  = true
    }
  ]
}
