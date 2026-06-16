locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name = local.component

  # Raw UAT output (wiedehopf readsb `uat_in` compatible) — what tar1090's
  # internal readsb pulls to merge 978 traffic onto the map.
  uat_port = 30978

  # Decoded JSON output, for any consumer that wants parsed UAT messages.
  json_port = 30979
}
