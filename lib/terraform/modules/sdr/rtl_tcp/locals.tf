locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name = local.component
  port = 1234

  # Tailnet device hostname for the off-cluster LoadBalancer (main_lb.tf).
  tailscale_hostname = coalesce(var.rtl_tcp.tailscale_hostname, "${local.name}-${local.environment}")
}
