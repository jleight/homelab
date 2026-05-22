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
