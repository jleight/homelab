locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = var.namespace

  hostname = "${var.openwebrx.subdomain}.${var.gateway_domain}"

  # OpenWebRX reaches the dongle over the network now, via the shared rtl_tcp
  # server, rather than claiming the USB device directly. Inject the rtl_tcp
  # service address (threaded in from the rtl_tcp component) as the mandatory
  # `remote` key on each rtl_tcp SDR device, so stack.hcl never hardcodes the
  # in-cluster service DNS.
  #
  # Built as a separate override map + try()-guarded merge rather than a
  # `cond ? merge(...) : dev` ternary: the ternary fails type-checking because
  # its branches are objects with differing attributes (one has `remote`, one
  # doesn't), which OpenTofu won't unify. try() sidesteps that — a missing key
  # just falls through to {}.
  sdr_remotes = {
    for k, dev in var.openwebrx.sdrs :
    k => { remote = "${var.rtl_tcp_host}:${var.rtl_tcp_port}" }
    if try(dev.type, "") == "rtl_tcp"
  }

  sdrs = {
    for k, dev in var.openwebrx.sdrs :
    k => merge(dev, try(local.sdr_remotes[k], {}))
  }

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

    sdrs = local.sdrs
  }
}
