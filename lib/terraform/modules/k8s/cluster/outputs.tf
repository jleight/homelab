output "domain" {
  value = local.enabled ? var.k8s_cluster.domain : null
}

output "node_ipv4s" {
  value = local.enabled ? values(local.node_ips.v4) : []
}

output "upgrade_machines" {
  value = {
    for k, v in local.nodes : k => join(
      " ",
      [
        "talosctl",
        "upgrade",
        "--nodes",
        local.node_ips.v4[k],
        "--image",
        local.node_images[k],
        "--preserve"
      ]
    )
  }
}
