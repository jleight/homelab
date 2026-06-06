locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = var.namespace

  vernemq_name      = local.name
  vernemq_host      = "${local.vernemq_name}.${local.namespace}.svc.cluster.local"
  vernemq_mqtt_port = 1883
}
