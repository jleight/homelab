locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = local.enabled ? kubernetes_namespace_v1.this[0].metadata[0].name : null

  hostname = "${var.openwebrx.subdomain}.${var.gateway_domain}"

  vault_uuid          = local.enabled ? data.onepassword_vault.terraform[0].uuid : null
  admin_user_username = local.enabled ? random_pet.admin_user[0].id : null
  admin_user_password = local.enabled ? random_password.admin_user[0].result : null
  admin_user_secret   = local.enabled ? kubernetes_secret_v1.admin_user[0].metadata[0].name : null

  settings_secret = local.enabled ? kubernetes_config_map_v1.settings_seed[0].metadata[0].name : null

  # Curated subset of OpenWebRX's settings.json that we want managed as code:
  # the receiver identity and the SDR device + band profiles, both sourced from
  # stack.hcl. Everything else (waterfall/FFT rendering, map prefs, the schema
  # `version`) is left for the web UI to own. The init container deep-merges
  # this over the live file, so any key omitted here (e.g. rf_gain) keeps
  # whatever value is already there.
  settings_seed = {
    receiver_name     = var.openwebrx.receiver.name
    receiver_location = var.openwebrx.receiver.location
    receiver_asl      = var.openwebrx.receiver.asl
    receiver_admin    = var.openwebrx.receiver.admin
    receiver_country  = var.openwebrx.receiver.country
    bandplan_region   = var.openwebrx.receiver.bandplan_region

    receiver_gps = {
      lat = var.openwebrx.receiver.gps.lat
      lon = var.openwebrx.receiver.gps.lon
    }

    sdrs = var.openwebrx.sdrs
  }
}
