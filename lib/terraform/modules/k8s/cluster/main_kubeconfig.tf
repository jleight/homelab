resource "talos_cluster_kubeconfig" "this" {
  count = local.enabled ? 1 : 0

  client_configuration = local.talos_client_config
  node                 = local.enabled ? values(local.node_ips)[0] : null

  depends_on = [talos_machine_bootstrap.this]
}

resource "local_sensitive_file" "kubeconfig" {
  count = local.enabled ? 1 : 0

  filename = local.kubeconfig_file
  content  = local.kubeconfig
}
