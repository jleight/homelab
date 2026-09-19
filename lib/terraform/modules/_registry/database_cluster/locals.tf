locals {
  cluster_name = "db"

  all_databases = merge(
    var.managed_databases,
    {
      app = {
        password_length  = 64
        password_special = false
      }
    }
  )
}
