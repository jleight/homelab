module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = local.namespace

  image               = var.zwave_js_ui.image
  image_version       = var.zwave_js_ui.version
  deployment_strategy = "Recreate"

  port = 8091

  extra_service_ports = [
    {
      name        = "ws"
      port        = 3000
      target_port = 3000
    }
  ]

  subdomain = var.zwave_js_ui.subdomain
  path      = var.zwave_js_ui.path

  gateway_refs   = var.gateway_refs
  gateway_domain = var.gateway_domain

  # Roll the pod (re-running the merge init) whenever the managed config changes.
  pod_annotations = {
    "checksum/config" = sha256(local.config_json)
  }

  # The gateway appends X-Forwarded-For, but Express defaults to
  # `trust proxy: false`, so express-rate-limit refuses to derive a client IP
  # from that header and throws ERR_ERL_UNEXPECTED_X_FORWARDED_FOR — leaving
  # every client sharing one rate-limit bucket keyed on the gateway's IP.
  # 1 = trust exactly one hop (the gateway). Not `true`, which trusts the whole
  # chain and lets a client spoof the leftmost XFF entry to evade the limiter.
  env = {
    TRUST_PROXY = "1"
  }

  init_containers = [
    {
      name        = "merge-config"
      image       = "${var.zwave_js_ui.yq.image}:${var.zwave_js_ui.yq.version}"
      run_as_user = 0

      command = [
        "sh", "-c",
        "f=/usr/src/app/store/settings.json; [ -f \"$f\" ] || echo '{}' > \"$f\"; yq -i -p=json -o=json '. *= load(\"/managed/settings.json\")' \"$f\""
      ]

      volume_mounts = [
        {
          name       = "data"
          mount_path = "/usr/src/app/store"
        },
        {
          name       = "managed-config"
          mount_path = "/managed"
          read_only  = true
        }
      ]
    }
  ]

  resource_limits = {
    (var.zwave_js_ui.device_resource) = "1"
  }

  # The Terraform-managed settings (local.config) are mounted read-only from a
  # Secret; an init container deep-merges them into the persisted settings.json
  # so our keys (serial port, WS server, security keys) win while zwave-js-ui's
  # runtime state is preserved. /usr/src/app/store is root-owned (zwave-js-ui
  # runs as root to open the root-owned /dev/zwave), and the yq image defaults
  # to uid 1000, so the merge runs as root.
  volumes_from_secrets = {
    "managed-config" = kubernetes_secret_v1.config[0].metadata[0].name
  }

  persistent_volume_claims = {
    data = {
      storage_class = var.data_storage_class
    }
  }

  volume_mounts = [
    {
      name       = "data"
      mount_path = "/usr/src/app/store"
    }
  ]
}
