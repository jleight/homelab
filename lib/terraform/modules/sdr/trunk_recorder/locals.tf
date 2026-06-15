locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name = local.component

  # Channels per system = non-empty channelFile rows minus the header row.
  system_channel_counts = {
    for s in var.trunk_recorder.systems :
    s.short_name => length([for l in split("\n", trimspace(s.channel_csv)) : l if trimspace(l) != ""]) - 1
  }

  # Each conventional channel needs a dedicated always-on recorder; size the
  # source's pools from the channel totals per type. concat([0], …) keeps sum()
  # happy when a type has no systems.
  digital_recorders = sum(concat([0], [
    for s in var.trunk_recorder.systems : local.system_channel_counts[s.short_name] if s.type == "conventionalP25"
  ]))
  analog_recorders = sum(concat([0], [
    for s in var.trunk_recorder.systems : local.system_channel_counts[s.short_name] if s.type == "conventional"
  ]))

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
        agc              = var.trunk_recorder.source.agc
        error            = var.trunk_recorder.source.error
        digitalRecorders = local.digital_recorders
        analogRecorders  = local.analog_recorders
        driver           = "osmosdr"
        device           = "rtl_tcp=${var.rtl_tcp_host}:${var.rtl_tcp_port}"
      }
    ]

    # modulation only applies to P25; the for-with-if merge keeps it out of analog
    # systems without a type-unifying ternary.
    systems = [
      for s in var.trunk_recorder.systems : merge(
        {
          shortName    = s.short_name
          type         = s.type
          channelFile  = "${s.short_name}.csv"
          squelch      = s.squelch
          audioArchive = true
        },
        { for k, v in { modulation = s.modulation } : k => v if s.modulation != null }
      )
    ]
  }

  # config.json plus one channelFile per system, all mounted into /app.
  config_files = merge(
    { "config.json" = jsonencode(local.config) },
    { for s in var.trunk_recorder.systems : "${s.short_name}.csv" => s.channel_csv }
  )

  config_cm = local.enabled ? kubernetes_config_map_v1.config[0].metadata[0].name : null
}
