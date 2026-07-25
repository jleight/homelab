resource "random_password" "user" {
  for_each = local.enabled ? toset(var.internal_users) : []

  length  = 32
  special = false
}
