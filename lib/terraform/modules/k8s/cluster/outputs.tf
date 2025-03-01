resource "local_sensitive_file" "kubeconfig" {
  count = local.enabled ? 1 : 0

  filename = "${var.dot_kube_directory}/${module.this.id}"

  content = local.kubeconfig
}
