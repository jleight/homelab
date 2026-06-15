locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name = local.component

  has_talkgroups = var.trunk_recorder.talkgroups_csv != ""
  is_trunked     = var.trunk_recorder.system.type == "p25"

  # Each fragment is a for-with-if yielding a homogeneous map (one entry or
  # none). Merging them sidesteps the conditional-object type-unification error a
  # `cond ? {...} : {}` ternary would hit, and keeps each value type clean (a map
  # can't mix list(number) channels with a number squelch, so they're separate).
  talkgroups_override = {
    for k, v in { talkgroupsFile = "talkgroups.csv" } : k => v
    if local.has_talkgroups
  }

  control_channels_override = {
    for k, v in { control_channels = var.trunk_recorder.system.control_channels } : k => v
    if local.is_trunked
  }

  channels_override = {
    for k, v in { channels = var.trunk_recorder.system.channels } : k => v
    if !local.is_trunked
  }

  squelch_override = {
    for k, v in { squelch = var.trunk_recorder.system.squelch } : k => v
    if !local.is_trunked
  }

  # Trunk Recorder's config.json (format ver 2). The rtl_tcp device string is
  # threaded in from the rtl_tcp component, never hardcoded here.
  config = {
    ver             = 2
    captureDir      = "/app/media"
    callTimeout     = 3
    logLevel        = "info"
    frequencyFormat = "mhz"
    controlWarnRate = 10

    sources = [
      {
        center           = var.trunk_recorder.source.center
        rate             = var.trunk_recorder.source.rate
        gain             = var.trunk_recorder.source.gain
        error            = var.trunk_recorder.source.error
        digitalRecorders = var.trunk_recorder.source.digital_recorders
        driver           = "osmosdr"
        device           = "rtl_tcp=${var.rtl_tcp_host}:${var.rtl_tcp_port}"
      }
    ]

    systems = [
      merge(
        {
          shortName     = var.trunk_recorder.system.short_name
          type          = var.trunk_recorder.system.type
          modulation    = var.trunk_recorder.system.modulation
          digitalLevels = 1
        },
        local.control_channels_override,
        local.channels_override,
        local.squelch_override,
        local.talkgroups_override,
      )
    ]
  }

  config_cm = local.enabled ? kubernetes_config_map_v1.config[0].metadata[0].name : null
}
