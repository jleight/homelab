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
            },
            {
              # Original Prusa i3 MK3 3D printer (CDC-ACM serial, plugged into prod-01).
              # → resource devices.k8s.leightha.us/prusa-mk3
              name = "prusa-mk3"
              groups = [
                {
                  paths = [
                    {
                      path      = "/dev/serial/by-id/usb-Prusa_Research*Original_Prusa_i3_MK3*-if00"
                      mountPath = "/dev/ttyACM0"
                    }
                  ]
                }
              ]
            },
            {
              # Home Assistant Connect ZBT-1 (Nabu Casa SkyConnect) combo radio.
              # → devices.k8s.leightha.us/zigbee
              name = "zigbee"
              groups = [
                {
                  paths = [
                    {
                      path      = "/dev/serial/by-id/usb-Nabu_Casa_SkyConnect_v1.0_*-if00-port0"
                      mountPath = "/dev/zigbee"
                    }
                  ]
                }
              ]
            },
            {
              # Home Assistant Connect ZWA-2 (Nabu Casa ZWA-2) Z-Wave radio.
              # → devices.k8s.leightha.us/zwave
              name = "zwave"
              groups = [
                {
                  paths = [
                    {
                      path      = "/dev/serial/by-id/usb-Nabu_Casa_ZWA-2_*-if00"
                      mountPath = "/dev/zwave"
                    }
                  ]
                }
              ]
            },
            {
              # RTL-SDR Blog V4 (Realtek RTL2832U) software-defined radio.
              # → devices.k8s.leightha.us/rtl-sdr
              name = "rtl-sdr"
              groups = [
                {
                  usb = [
                    {
                      vendor  = "0bda"
                      product = "2838"
                      serial  = "00000001"
                    }
                  ]
                }
              ]
            },
            {
              # Nooelec NESDR Nano 3 (RTL2832U) on the 1090 MHz antenna for ADS-B.
              # → devices.k8s.leightha.us/sdr-adsb
              name = "sdr-adsb"
              groups = [
                {
                  usb = [
                    {
                      vendor  = "0bda"
                      product = "2838"
                      serial  = "stx:1090:0"
                    }
                  ]
                }
              ]
            },
            {
              # Nooelec NESDR Nano 3 (RTL2832U) on the 978 MHz antenna for UAT.
              # → devices.k8s.leightha.us/sdr-uat
              name = "sdr-uat"
              groups = [
                {
                  usb = [
                    {
                      vendor  = "0bda"
                      product = "2838"
                      serial  = "stx:978:0"
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
