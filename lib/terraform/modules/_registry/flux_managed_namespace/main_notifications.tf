resource "kubernetes_secret_v1" "discord_notifications" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "discord-notifications"
  }

  data = {
    address = local.discord_notifications_webhook_address
  }
}
