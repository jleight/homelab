locals {
  discord_webhook_url     = local.enabled ? data.onepassword_item.discord_webhook[0].url : null
  discord_webhook_key     = local.enabled ? data.onepassword_item.discord_webhook[0].password : null
  discord_webhook_address = "${local.discord_webhook_url}/${local.discord_webhook_key}"
}
