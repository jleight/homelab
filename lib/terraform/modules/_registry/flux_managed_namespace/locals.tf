locals {
  name    = coalesce(var.name, local.stack)
  part_of = coalesce(var.part_of, local.stack)

  namespace = local.enabled ? kubernetes_namespace_v1.this[0].metadata[0].name : null

  discord_notifications_webhook_url     = local.enabled ? data.onepassword_item.discord_notifications_webhook[0].url : null
  discord_notifications_webhook_key     = local.enabled ? data.onepassword_item.discord_notifications_webhook[0].password : null
  discord_notifications_webhook_address = "${local.discord_notifications_webhook_url}/${local.discord_notifications_webhook_key}"
}
