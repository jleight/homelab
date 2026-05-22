resource "kubernetes_secret_v1" "broker_home_assistant" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-broker-home-assistant"
  }

  data = {
    username = data.onepassword_item.ha_mqtt[0].username
    password = data.onepassword_item.ha_mqtt[0].credential
  }
}

resource "kubernetes_secret_v1" "broker_vernemq" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-broker-vernemq"
  }

  data = {
    username = var.vernemq_username
    password = var.vernemq_password
  }
}
