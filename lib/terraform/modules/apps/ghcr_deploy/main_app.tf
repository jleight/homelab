module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = local.namespace

  image         = var.ghcr_deploy.image
  image_version = var.ghcr_deploy.version

  # Stock Python image, so the entrypoint is replaced outright with the mounted
  # script. -u keeps pod logs unbuffered.
  command = ["python", "-u", "/app/ghcr_deploy.py"]

  port = local.port

  subdomain = var.ghcr_deploy.subdomain
  path      = var.ghcr_deploy.webhook_path

  gateway_refs   = var.gateway_refs
  gateway_domain = var.gateway_domain

  # Nothing in the image runs as root and nothing is written to disk; the script
  # only needs to read its own ConfigMap and the projected SA token.
  run_as_user     = 65532
  run_as_non_root = true

  env = {
    GHCR_DEPLOY_PORT    = tostring(local.port)
    GHCR_DEPLOY_PATH    = var.ghcr_deploy.webhook_path
    GHCR_DEPLOY_TARGETS = "/etc/ghcr-deploy/targets.json"
  }

  env_from_secrets = [local.secret_name]

  # Both the code and the allowlist are read once at startup, so hash them into
  # the pod template to make Terraform roll the pod when either changes.
  pod_annotations = {
    "checksum/code"    = sha256(local.code)
    "checksum/targets" = sha256(local.targets_json)
  }

  resource_requests = {
    cpu    = "10m"
    memory = "32Mi"
  }

  resource_limits = {
    memory = "128Mi"
  }

  volumes_from_config_maps = {
    config = local.config_name
  }

  volume_mounts = [
    {
      name       = "config"
      mount_path = "/app/ghcr_deploy.py"
      sub_path   = "ghcr_deploy.py"
      read_only  = true
    },
    {
      name       = "config"
      mount_path = "/etc/ghcr-deploy/targets.json"
      sub_path   = "targets.json"
      read_only  = true
    }
  ]
}
