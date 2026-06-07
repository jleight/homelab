module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = local.namespace

  image         = var.matter_server.image
  image_version = var.matter_server.version

  port = 5580

  # Matter commissioning relies on mDNS discovery on the local subnet, which the
  # pod-network overlay hides — so the server needs host networking.
  host_network = true

  # Mirrors the image's default CMD (storage + PAA cert dir under /data) and
  # adds --primary-interface to scope mDNS to the LAN NIC. args fully replaces
  # the image CMD, so the defaults must be repeated here.
  args = [
    "--storage-path",
    "/data",
    "--paa-root-cert-dir",
    "/data/credentials",
    "--primary-interface",
    var.matter_server.primary_interface
  ]

  # No web UI — it's a websocket server (ws://matter-server.home.svc:5580/ws)
  # that HA connects to in-cluster. Nothing to expose externally.
  ingress_enabled = false

  persistent_volume_claims = {
    data = {
      storage_class = var.data_storage_class
      storage_size  = var.matter_server.storage_size
    }
  }

  volume_mounts = [
    {
      name       = "data"
      mount_path = "/data"
    }
  ]
}
