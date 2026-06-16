locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name     = local.component
  hostname = "${var.audioplayer.subdomain}.${var.gateway_domain}"

  # Upstream audioplayer.php, patched for our container: serve from /var/www/html
  # (so file paths become Apache URLs), read config.json from an absolute path
  # (mod_php CWD is unreliable), and swap the removed-in-PHP-9 strftime for date.
  script_raw = local.enabled ? data.http.audioplayer[0].response_body : ""
  script = replace(replace(replace(replace(replace(
    local.script_raw,
    "date_default_timezone_set('America/New_York')", "date_default_timezone_set('${var.audioplayer.timezone}')"),
    "$base_directory_name = '/home/trunkrecorder';", "$base_directory_name = '/var/www/html';"),
    "'./../configs/config.json'", "'/var/www/configs/config.json'"),
    "strftime('%F', $TIME)", "date('Y-m-d', $TIME)"),
    "strftime('%F')", "date('Y-m-d')"
  )

  # A talkgroup file per system so calls show friendly names instead of bare TG
  # numbers. Emitted in the script's "standard" (non-RadioReference) layout —
  # Decimal,Hex,Mode,Alpha Tag,Description,Tag,Group,Priority — with NO header:
  # the script parses every line with this 8-column layout, so a header (or the
  # 7-column RadioReference variant) trips an "Undefined array key 7" warning that
  # corrupts the page. Rows derive from each system's channelFile columns
  # (TG Number,Frequency,Tone,Alpha Tag,Description,Tag).
  talkgroup_files = {
    for s in var.systems :
    s.short_name => join("\n", [
      for line in slice(
        [for l in split("\n", trimspace(s.channel_csv)) : l if trimspace(l) != ""],
        1,
        length([for l in split("\n", trimspace(s.channel_csv)) : l if trimspace(l) != ""])
      ) :
      format("%s,,%s,%s,%s,%s,,",
        trimspace(element(split(",", line), 0)), # Decimal = TG Number
        s.type == "conventionalP25" ? "D" : "A", # Mode
        trimspace(element(split(",", line), 3)), # Alpha Tag
        trimspace(element(split(",", line), 4)), # Description
        trimspace(element(split(",", line), 5)), # Tag
      )
    ])
  }

  # audioplayer.php reads this for captureDir + the systems to scan, and each
  # system's talkgroupsFile for the names.
  config = {
    captureDir = "/var/www/html/media"
    systems = [
      for s in var.systems : {
        shortName      = s.short_name
        talkgroupsFile = "/var/www/configs/${s.short_name}-talkgroups.csv"
      }
    ]
  }

  config_files = merge(
    {
      "index.php"   = local.script
      "config.json" = jsonencode(local.config)
      # Keep PHP warnings/notices out of the HTTP body — they'd corrupt the
      # player's AJAX JSON. Errors still go to the container log.
      "php.ini" = "display_errors = Off\nlog_errors = On\n"
    },
    { for name, csv in local.talkgroup_files : "${name}-talkgroups.csv" => csv }
  )

  config_cm = local.enabled ? kubernetes_config_map_v1.config[0].metadata[0].name : null
}
