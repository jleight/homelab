locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name = local.component

  hostname = "${var.tar1090.subdomain}.${var.gateway_domain}"

  # Effective upstreams: an explicit host override (e.g. the Pi) wins, and its
  # port travels with it; otherwise fall back to the in-cluster readsb/dump978
  # threaded via dependency outputs. So a band only leaves the cluster when its
  # host is explicitly set.
  beast_host = coalesce(var.tar1090.beast_host, var.readsb_host)
  beast_port = var.tar1090.beast_host != null ? var.tar1090.beast_port : var.readsb_port

  uat_host = coalesce(var.tar1090.uat_host, var.dump978_host)
  uat_port = var.tar1090.uat_host != null ? var.tar1090.uat_port : var.dump978_uat_port

  # tar1090's internal readsb merges two upstreams onto one map: the 1090 Beast
  # feed (BEASTHOST) and the 978 UAT feed pulled as a `uat_in` net connector.
  # Connector syntax: host,port,protocol[;...].
  uat_connector = "${local.uat_host},${local.uat_port},uat_in"
}
