# readsb decodes 1090 MHz Mode-S/ADS-B straight off the RTL-SDR on the 1090
# antenna and serves the decoded aircraft as a Beast stream on TCP 30005. tar1090
# connects to that stream for the map; nothing else claims the dongle, so this
# owns it exclusively (hence Recreate, like rtl_tcp).
module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = var.namespace
  replicas  = var.readsb.replicas

  image               = var.readsb.image
  image_version       = var.readsb.version
  deployment_strategy = "Recreate"

  # Raw Beast TCP only — no HTTP UI here (tar1090 renders the map). The
  # ClusterIP Service carries 30005 for in-cluster consumers.
  port            = local.beast_port
  service_port    = local.beast_port
  ingress_enabled = false

  # No device selection needed: the plugin mounts only the sdr-adsb dongle's
  # /dev/bus/usb node into the pod, so readsb finds it as the sole device. The
  # NESDR Nano 3 is an RTL2832U dongle, so the rtlsdr driver is correct.
  env = {
    READSB_NET_ENABLE  = "true"
    READSB_DEVICE_TYPE = "rtlsdr"
    READSB_GAIN        = var.readsb.gain
    READSB_LAT         = tostring(var.readsb.latitude)
    READSB_LON         = tostring(var.readsb.longitude)
  }

  # Requesting the device-plugin resource pins the pod to the node with the
  # 1090 dongle attached and mounts the matching /dev/bus/usb node in with the
  # right cgroup permissions. Kubernetes mirrors extended-resource limits into
  # requests.
  resource_limits = {
    (var.readsb.device_resource) = "1"
  }
}
