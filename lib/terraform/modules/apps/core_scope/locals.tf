locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = local.enabled ? kubernetes_namespace_v1.this[0].metadata[0].name : null

  port = 3000

  vault_uuid = local.enabled ? data.onepassword_vault.terraform[0].uuid : null

  mqtt_hostname = local.enabled ? data.onepassword_item.ha_mqtt[0].hostname : null
  mqtt_username = local.enabled ? data.onepassword_item.ha_mqtt[0].username : null
  mqtt_password = local.enabled ? data.onepassword_item.ha_mqtt[0].credential : null

  api_key = local.enabled ? random_password.api_key[0].result : null

  config_json = jsonencode(merge(
    {
      port   = local.port
      apiKey = local.api_key

      mqttSources = [
        {
          name     = "home-assistant"
          broker   = "mqtt://${local.mqtt_hostname}:1883"
          username = local.mqtt_username
          password = local.mqtt_password
          topics = [
            "meshcore/+/+/packets",
            "meshcore/#"
          ]
        }
      ]

      channelKeys  = var.core_scope.channel_keys
      hashChannels = var.core_scope.hash_channels
      regions      = var.core_scope.regions
    },
    var.core_scope.default_region == null ? {} : {
      defaultRegion = var.core_scope.default_region
    },
    var.core_scope.map_defaults == null ? {} : {
      mapDefaults = {
        center = var.core_scope.map_defaults.center
        zoom   = var.core_scope.map_defaults.zoom
      }
    }
  ))

  match_labels = {
    "app.kubernetes.io/name"     = local.name
    "app.kubernetes.io/instance" = local.name
  }

  labels = merge(
    local.match_labels,
    {
      "app.kubernetes.io/version"    = var.core_scope.version
      "app.kubernetes.io/component"  = local.name
      "app.kubernetes.io/part-of"    = local.stack
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  )

  hostname = "${var.core_scope.subdomain}.${var.gateway_domain}"

  # Litestream replicates to the backup PVC mounted at /backup.
  # One YAML file rendered into a ConfigMap and mounted at /etc/litestream.yml.
  litestream_config = yamlencode({
    dbs = [
      {
        path = "/app/data/meshcore.db"
        replicas = [
          {
            type                     = "file"
            path                     = "/backup/meshcore"
            retention                = "168h"
            retention-check-interval = "1h"
            sync-interval            = "1s"
          }
        ]
      }
    ]
  })
}
