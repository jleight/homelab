locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name = local.component
  port = 1234

  # Hostname for the LAN VIP. external-dns (service source) creates the A record
  # from the assigned LoadBalancer IP.
  hostname = "${var.rtl_tcp.subdomain}.${var.gateway_domain}"
}
