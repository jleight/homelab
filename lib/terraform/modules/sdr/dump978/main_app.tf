# dump978 decodes 978 MHz UAT off the RTL-SDR on the 978 antenna and serves the
# raw stream on TCP 30978 (and decoded JSON on 30979). tar1090's internal readsb
# pulls 30978 as a `uat_in` connector to fold UAT aircraft onto the same map as
# the 1090 traffic. Owns its dongle exclusively (Recreate).
module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = var.namespace
  replicas  = var.dump978.replicas

  image               = var.dump978.image
  image_version       = var.dump978.version
  deployment_strategy = "Recreate"

  # Raw UAT TCP (30978) as the primary Service port; decoded JSON (30979)
  # alongside it. No HTTP UI.
  port            = local.uat_port
  service_port    = local.uat_port
  ingress_enabled = false

  extra_service_ports = [
    {
      name        = "json"
      port        = local.json_port
      target_port = local.json_port
    }
  ]

  # Pins the pod to the node with the 978 dongle and mounts its /dev/bus/usb node.
  resource_limits = {
    (var.dump978.device_resource) = "1"
  }
}
