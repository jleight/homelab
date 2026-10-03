locals {
  cluster_name = "db"

  # The databases each user owns, defaulting to one named after the user.
  user_databases = {
    for k, v in var.managed_databases : k => v.databases != null ? sort(v.databases) : [k]
  }

  # Every database to create, keyed by name, with the user that owns it.
  databases = merge([
    for k, v in var.managed_databases : {
      for name in local.user_databases[k] : name => {
        owner      = k
        extensions = v.extensions
      }
    }
  ]...)

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
