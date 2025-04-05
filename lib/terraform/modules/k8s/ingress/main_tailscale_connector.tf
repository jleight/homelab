resource "kubectl_manifest" "tailscale_connector" {
  count = local.tailscale_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "tailscale.com/v1alpha1"
    kind       = "Connector"

    metadata = {
      name = "connector-${local.stack}-${local.environment}"
    }

    spec = {
      hostname = "tailscale-connector-${local.stack}-${local.environment}"
      exitNode = true

      subnetRouter = {
        advertiseRoutes = [
          module.ipam.lan.v4_cidr,
          module.ipam.lan.v6_cidr,
          module.ipam.resources.pods,
          module.ipam.resources.services,
          module.ipam.resources.load_balancers,
        ]
      }
    }
  })

  depends_on = [helm_release.tailscale]
}
