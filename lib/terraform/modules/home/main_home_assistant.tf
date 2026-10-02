locals {
  home_assistant_db = module.database_cluster.databases["homeassistant"]

  home_assistant_database_url = join("", [
    "postgresql://${local.home_assistant_db.username}:${module.database_cluster.passwords["homeassistant"]}",
    "@${module.database_cluster.host}:${module.database_cluster.port}/${local.home_assistant_db.database}",
    "?sslmode=require"
  ])
}

# The recorder's connection string. The committed overlay makes
# configuration.yaml read it with !env_var.
resource "kubernetes_secret_v1" "home_assistant" {
  metadata {
    namespace = module.namespace.name
    name      = "home-assistant"
  }

  data = {
    HASS_RECORDER_DB_URL = local.home_assistant_database_url
  }
}

# Values the Deployment reads with envFrom. Reference them from
# configuration.yaml, e.g.:
#   mqtt:
#     broker: !env_var HASS_MQTT_HOST
#     port: !env_var HASS_MQTT_PORT
resource "kubernetes_config_map_v1" "home_assistant_env" {
  metadata {
    namespace = module.namespace.name
    name      = "home-assistant-env"
  }

  data = {
    HASS_MQTT_HOST = local.mqtt_host
    HASS_MQTT_PORT = tostring(local.mqtt_port)
  }
}

# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "home_assistant_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "home-assistant-subst"
  }

  data = {
    data_storage_class    = var.data_storage_class
    backups_storage_class = var.backups_storage_class
    gateway_parent_refs   = jsonencode(var.gateway_refs)
    domain                = "${var.home_assistant.subdomain}.${var.gateway_domain}"
    secret_checksum       = "sha256:${sha256(jsonencode(kubernetes_secret_v1.home_assistant.data))}"
  }
}
