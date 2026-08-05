locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = var.namespace

  # Config overlay deep-merged into /config/configuration.yaml by an init
  # container before HA starts: these keys win, the rest of the user's config
  # (and its comments / !secret / !include tags) is preserved. Raw YAML, so HA
  # custom tags survive — add any HA config here to manage it declaratively.
  #
  # recorder.db_url points the recorder at the CNPG Postgres cluster instead of
  # the default write-heavy SQLite, which corrupts on replicated Longhorn. This
  # is enforced here (not just via the injected env var) because HA only honors
  # the env var if configuration.yaml actually references it — a default or
  # restored-from-HAOS config does not, and would silently fall back to SQLite.
  config_overlay = join("\n", [
    "# Managed by the home_assistant Terraform module — merged into this file",
    "# by the merge-config init container. Edit the module, not here.",
    "recorder:",
    "  db_url: !env_var HASS_RECORDER_DB_URL"
  ])
}
