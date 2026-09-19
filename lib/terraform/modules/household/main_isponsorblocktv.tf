locals {
  isponsorblocktv_config = jsonencode({
    devices = [
      {
        name      = var.isponsorblocktv.device_name
        screen_id = data.onepassword_item.device_screen_id.credential
      }
    ]
    apikey              = var.isponsorblocktv.api_key
    skip_categories     = var.isponsorblocktv.skip_categories
    channel_whitelist   = var.isponsorblocktv.channel_whitelist
    skip_count_tracking = var.isponsorblocktv.skip_count_tracking
    mute_ads            = var.isponsorblocktv.mute_ads
    skip_ads            = var.isponsorblocktv.skip_ads
    minimum_skip_length = var.isponsorblocktv.minimum_skip_length
    auto_play           = var.isponsorblocktv.auto_play
    join_name           = var.isponsorblocktv.join_name
  })
}

resource "kubernetes_secret_v1" "isponsorblocktv" {
  metadata {
    namespace = module.namespace.name
    name      = "isponsorblocktv-config"
  }

  data = {
    "config.json" = local.isponsorblocktv_config
  }
}

resource "kubernetes_config_map_v1" "isponsorblocktv_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "isponsorblocktv-subst"
  }

  data = {
    config_secret   = kubernetes_secret_v1.isponsorblocktv.metadata[0].name
    config_checksum = "sha256:${sha256(local.isponsorblocktv_config)}"
  }
}
