# tar1090 is the live aircraft map. It runs its own net-only readsb that ingests
# the 1090 Beast stream (BEASTHOST) and the 978 UAT stream (READSB_NET_CONNECTOR
# uat_in), then renders both bands on one map served over HTTP. Claims no SDR, so
# it can land on any node and reaches the decoders over the cluster network.
module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = var.namespace

  image         = var.tar1090.image
  image_version = var.tar1090.version

  port = 80

  subdomain = var.tar1090.subdomain
  path      = var.tar1090.path

  gateway_refs   = var.gateway_refs
  gateway_domain = var.gateway_domain

  env = {
    BEASTHOST = local.beast_host
    BEASTPORT = tostring(local.beast_port)

    READSB_NET_CONNECTOR = local.uat_connector
    MAX_GLOBE_HISTORY    = tostring(var.tar1090.history_retention_days)

    LAT  = tostring(var.tar1090.latitude)
    LONG = tostring(var.tar1090.longitude)
  }

  persistent_volume_claims = {
    history = {
      storage_class = var.data_storage_class
      storage_size  = var.tar1090.storage_size
    }
  }

  volume_mounts = [
    {
      name       = "history"
      mount_path = "/var/globe_history"
      sub_path   = "globe_history"
    },
    {
      name       = "history"
      mount_path = "/var/lib/collectd/rrd"
      sub_path   = "collectd-rrd"
    }
  ]
}
