resource "kubernetes_namespace_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    name = local.name

    # Home Assistant, the Matter server, and Homebridge all run with host
    # networking, and the Z-Wave/Zigbee pods mount host USB devices — all of
    # which require the privileged Pod Security Standard. The whole shared
    # `home` namespace runs privileged as a result.
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}
