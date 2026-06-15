# A plain rtl_tcp server fronting the RTL-SDR dongle. OpenWebRX, OP25 and the
# iOS app all connect to this as clients instead of claiming the USB device
# directly — rtl_tcp serves one client at a time, so they're mutually exclusive
# (first-come, not preemptive), which is acceptable here.
module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = var.namespace

  image               = var.rtl_tcp.image
  image_version       = var.rtl_tcp.version
  deployment_strategy = "Recreate"

  # Set the full command rather than rely on the image's entrypoint defaults:
  # bind all interfaces, fixed port, first device.
  command = [
    "rtl_tcp",
    "-a",
    "0.0.0.0",
    "-p",
    tostring(local.port),
    "-d",
    "0"
  ]

  # No HTTP app; just a raw TCP server. The app_deployment ClusterIP Service
  # carries this port for in-cluster clients; the LAN LoadBalancer is separate.
  port            = local.port
  service_port    = local.port
  ingress_enabled = false

  # Requesting the device-plugin resource pins the pod to the node with the
  # RTL-SDR attached and mounts the matching /dev/bus/usb node in with the right
  # cgroup permissions. Kubernetes mirrors extended-resource limits into requests.
  resource_limits = {
    (var.rtl_tcp.device_resource) = "1"
  }
}
