module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = local.namespace

  image         = var.reverse_proxy.image
  image_version = var.reverse_proxy.version

  port         = 8080
  service_port = 8080

  ingress_enabled = false

  pod_annotations = {
    "config-hash" = sha256(kubernetes_config_map_v1.nginx[0].data["nginx.conf"])
  }

  volumes_from_config_maps = {
    config = kubernetes_config_map_v1.nginx[0].metadata[0].name
  }

  volume_mounts = [
    {
      name       = "config"
      mount_path = "/etc/nginx/nginx.conf"
      sub_path   = "nginx.conf"
      read_only  = true
    }
  ]
}
