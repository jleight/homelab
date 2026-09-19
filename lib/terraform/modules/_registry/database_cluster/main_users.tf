resource "random_password" "user" {
  for_each = local.all_databases

  length  = each.value.password_length
  special = each.value.password_special
}

resource "kubernetes_secret_v1" "credentials" {
  for_each = local.all_databases

  metadata {
    namespace = var.namespace
    name      = "${local.cluster_name}-${each.key}-credentials"
  }

  data = {
    username = each.key
    password = random_password.user[each.key].result
  }
}
