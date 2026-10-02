module "namespace" {
  source  = "../_registry/flux_managed_namespace"
  context = local.context

  vault = var.vault

  # Home Assistant, the Matter server and ESPHome run with host networking, and
  # the Z-Wave/Zigbee pods mount host USB devices — all of which require the
  # privileged Pod Security Standard.
  pod_security_enforcement = "privileged"
}
