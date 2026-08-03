locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  monitoring_namespace = try(one(kubernetes_namespace_v1.this[0].metadata).name, null)
}
