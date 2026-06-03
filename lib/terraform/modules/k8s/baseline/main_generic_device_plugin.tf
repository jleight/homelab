# Exposes specific host USB devices to pods as schedulable extended resources.
# A pod that requests `devices.k8s.leightha.us/<name>` is placed by the scheduler
# onto whichever node currently has a matching device free — that's what gives
# the pyMC repeater modem failover across the two nodes it's plugged into.
#
# Devices are matched by their stable /dev/serial/by-id symlink (vendor/product/
# serial) and remapped to a constant in-container path via mountPath, so the app
# sees the same path regardless of which node it lands on. Register new USB
# hardware by adding entries to the `devices` list below.
resource "helm_release" "generic_device_plugin" {
  count = local.enabled ? 1 : 0

  namespace  = "kube-system"
  name       = "generic-device-plugin"
  repository = var.k8s_baseline.generic_device_plugin.repository
  chart      = var.k8s_baseline.generic_device_plugin.chart
  version    = var.k8s_baseline.generic_device_plugin.version

  values = [
    yamlencode({
      # Prefix for the advertised resource names (resource = DOMAIN/<device name>).
      env = {
        DOMAIN = "devices.k8s.leightha.us"
      }

      config = {
        enabled = true
        data = yamlencode({
          devices = [
            {
              # MeshCore KISS modem (Silicon Labs CP210x USB-UART bridge).
              # → resource devices.k8s.leightha.us/meshcore
              name = "meshcore"
              groups = [
                {
                  paths = [
                    {
                      path      = "/dev/serial/by-id/usb-Silicon_Labs_CP210*-if00-port0"
                      mountPath = "/dev/ttyUSB0"
                    }
                  ]
                }
              ]
            }
          ]
        })
      }
    })
  ]
}
