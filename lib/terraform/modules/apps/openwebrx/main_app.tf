module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = local.namespace

  image               = var.openwebrx.image
  image_version       = var.openwebrx.version
  deployment_strategy = "Recreate"

  port = 8073

  # A ConfigMap content change doesn't alter the pod template, so it wouldn't
  # roll the pod or re-run the seed init container on its own. Hash the seed
  # into a pod annotation so editing the settings in stack.hcl rolls the pod
  # (Recreate tears the old one down first, freeing the device) and re-merges.
  pod_annotations = {
    "leightha.us/settings-seed-hash" = sha256(jsonencode(local.settings_seed))
  }

  subdomain = var.openwebrx.subdomain
  path      = var.openwebrx.path

  gateway_namespace = var.gateway_namespace
  gateway_name      = var.gateway_name
  gateway_section   = var.gateway_section
  gateway_domain    = var.gateway_domain

  env = {
    TZ = var.openwebrx.timezone
  }

  secret_env = {
    OPENWEBRX_ADMIN_USER = {
      secret_name = local.admin_user_secret
      key         = "username"
    }
    OPENWEBRX_ADMIN_PASSWORD = {
      secret_name = local.admin_user_secret
      key         = "password"
    }
  }

  # Requesting the device-plugin resource is what makes the scheduler place this
  # pod on the node with the RTL-SDR attached, and what mounts the matching
  # /dev/bus/usb node into the container with the right cgroup permissions.
  # Kubernetes mirrors extended-resource limits into requests automatically.
  resource_limits = {
    (var.openwebrx.device_resource) = "1"
  }

  # A single PVC holds both the config and data trees, each under its own
  # sub_path so they stay isolated within the one volume.
  persistent_volume_claims = {
    data = {
      storage_class = var.data_storage_class
    }
  }

  # /tmp is backed by an emptyDir so dump1090 and friends get fast scratch space
  # without writing through a PVC (mirrors the compose tmpfs mount).
  volumes_empty_dir = ["tmp"]

  volumes_from_config_maps = {
    "settings-seed" = local.settings_secret
  }

  # Deep-merge the Terraform-managed receiver identity + SDR profiles
  # (local.settings_seed) over the live settings.json before OpenWebRX starts.
  # `.[0] * .[1]` makes our keys win while preserving anything else the web UI
  # owns (rendering prefs, UI-added profiles, rf_gain — which we never set). The
  # schema version is left as-is, or defaulted to 8 on a fresh, empty volume.
  # Reuses the OpenWebRX image (ships jq) and chowns the file back to the
  # openwebrx user (uid 103) so the app can keep rewriting it at runtime.
  init_containers = [
    {
      name = "seed-settings"

      command = [
        "sh", "-c",
        join(" ", [
          "set -e;",
          "f=/var/lib/openwebrx/settings.json;",
          "[ -s \"$f\" ] || echo '{}' > \"$f\";",
          "jq -s '.[0] * .[1] | (.version //= 8)' \"$f\" /seed/settings.json > \"$f.tmp\";",
          "mv \"$f.tmp\" \"$f\";",
          "chown 103:104 \"$f\"",
        ])
      ]

      volume_mounts = [
        {
          name       = "data"
          mount_path = "/var/lib/openwebrx"
          sub_path   = "var"
        },
        {
          name       = "settings-seed"
          mount_path = "/seed"
          read_only  = true
        }
      ]
    }
  ]

  volume_mounts = [
    {
      name       = "data"
      mount_path = "/etc/openwebrx"
      sub_path   = "config"
    },
    {
      name       = "data"
      mount_path = "/var/lib/openwebrx"
      sub_path   = "var"
    },
    {
      name       = "tmp"
      mount_path = "/tmp"
    }
  ]
}
