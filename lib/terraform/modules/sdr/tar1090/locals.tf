locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name = local.component

  hostname = "${var.tar1090.subdomain}.${var.gateway_domain}"

  # tar1090's internal readsb merges two upstreams onto one map: the 1090 Beast
  # feed from readsb (BEASTHOST) and the 978 UAT feed pulled from dump978 as a
  # `uat_in` net connector. Connector syntax: host,port,protocol[;...].
  uat_connector = "${var.dump978_host},${var.dump978_uat_port},uat_in"
}
