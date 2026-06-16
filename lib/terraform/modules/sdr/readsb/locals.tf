locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name = local.component

  # Beast output: the binary Mode-S stream tar1090 (and any other consumer)
  # connects to. readsb's default output port.
  beast_port = 30005
}
