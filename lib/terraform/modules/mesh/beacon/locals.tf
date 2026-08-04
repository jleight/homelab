locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = var.namespace

  # Two deployables: the Go backend (ingest + API) and the React bundle.
  server_name = local.name
  web_name    = "${local.name}-web"

  server_port = 8080
  web_port    = 80

  config_path = "/etc/beacon/config.yaml"

  hostname = "${var.beacon.subdomain}.${var.gateway_domain}"

  secret_name     = local.enabled ? kubernetes_secret_v1.app[0].metadata[0].name : null
  config_map_name = local.enabled ? kubernetes_config_map_v1.app[0].metadata[0].name : null

  database_url = "postgres://${var.db_username}:${var.db_password}@${var.db_host}:${var.db_port}/beacon?sslmode=disable"

  # Slot 1 is the in-cluster broker; slot 2 is optional (see var.beacon).
  brokers = merge(
    {
      MQTT_BROKER_1_URL      = "mqtt://${var.vernemq_host}:1883"
      MQTT_BROKER_1_USERNAME = var.vernemq_username
      MQTT_BROKER_1_PASSWORD = var.vernemq_password
    },
    var.beacon.second_broker == null ? {} : {
      MQTT_BROKER_2_URL      = var.beacon.second_broker.url
      MQTT_BROKER_2_USERNAME = var.beacon.second_broker.username
      MQTT_BROKER_2_PASSWORD = var.beacon.second_broker.password
    }
  )

  # Optional region fields are dropped rather than emitted as YAML nulls so
  # Beacon falls back to its own defaults for anything left unset.
  config_regions = [
    for r in var.beacon.regions : merge(
      {
        slug  = r.slug
        name  = r.name
        iatas = r.iatas
      },
      r.display_order == null ? {} : { display_order = r.display_order },
      r.center_lat == null ? {} : { center_lat = r.center_lat },
      r.center_lng == null ? {} : { center_lng = r.center_lng },
      r.zoom_level == null ? {} : { zoom_level = r.zoom_level }
    )
  ]

  # Only emitted when set, so anything left null keeps Beacon's own default.
  config_nodes = merge(
    var.beacon.node_delete_after == null ? {} : {
      delete_after = var.beacon.node_delete_after
    },
    var.beacon.node_stale_threshold == null ? {} : {
      stale_threshold = var.beacon.node_stale_threshold
    }
  )

  config_yaml = yamlencode(merge(length(local.config_nodes) == 0 ? {} : {
    nodes = local.config_nodes
    }, {
    iatas = {
      for iata, details in var.beacon.iatas : iata => {
        name = details.name
        lat  = details.lat
        lng  = details.lng
      }
    }

    regions = local.config_regions

    channel_keys = {
      hashtags = sort(var.beacon.hashtag_channels)
      keys = {
        for hash, channel in var.beacon.channel_keys : hash => {
          key  = channel.key
          name = channel.name
        }
      }
    }

    scopes = [for s in sort(var.beacon.scopes) : { name = s }]

    telemetry = {
      retention  = var.beacon.telemetry_retention
      resolution = var.beacon.telemetry_resolution
    }

    packets = {
      retention = var.beacon.packet_retention
    }

    websocket = {
      max_connections_per_ip = var.beacon.max_connections_per_ip
    }
  }))

  # The browser — not the pod — is what calls these, so they're absolute URLs on
  # the frontend's own hostname. Routing /api/v1 and /ws there to the server (see
  # api_rules below) keeps the API same-origin, which sidesteps CORS entirely.
  web_env = merge(
    {
      VITE_API_BASE = "https://${local.hostname}/api/v1"
      VITE_WS_URL   = "wss://${local.hostname}/ws"
    },
    # Unset options are left out of the env entirely — the image's entrypoint
    # has its own defaults for each.
    var.beacon.map_center == null ? {} : {
      VITE_MAP_CENTER = join(",", [for c in var.beacon.map_center : tostring(c)])
    },
    var.beacon.map_zoom == null ? {} : {
      VITE_MAP_ZOOM = tostring(var.beacon.map_zoom)
    },
    var.beacon.app_name == null ? {} : {
      VITE_APP_NAME = var.beacon.app_name
    },
    length(var.beacon.disabled_tabs) == 0 ? {} : {
      VITE_DISABLED_TABS = join(",", sort(var.beacon.disabled_tabs))
    },
    length(var.beacon.enabled_themes) == 0 ? {} : {
      VITE_ENABLED_THEMES = join(",", sort(var.beacon.enabled_themes))
    },
    var.beacon.skip_splash == null ? {} : {
      VITE_SKIP_SPLASH = tostring(var.beacon.skip_splash)
    }
  )

  api_rules = [
    for prefix in ["/api/v1", "/ws"] : {
      matches = [
        {
          path = {
            type  = "PathPrefix"
            value = prefix
          }
        }
      ]
      backendRefs = [
        {
          name = local.enabled ? module.server.service_name : null
          port = 80
        }
      ]
    }
  ]
}
