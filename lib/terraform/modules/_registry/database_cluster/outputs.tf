output "host" {
  description = "The read/write service for the cluster."
  value       = "${local.cluster_name}-rw.${var.namespace}.svc.cluster.local"
}

output "port" {
  description = "The port the cluster listens on."
  value       = 5432
}

output "databases" {
  description = "The database name, owner and credentials secret for each managed database."

  value = {
    for k, v in var.managed_databases : k => {
      database = k
      username = k
      secret   = kubernetes_secret_v1.credentials[k].metadata[0].name
    }
  }
}

output "passwords" {
  description = "The password for each managed database's owner, for consumers that need to compose a connection string."
  sensitive   = true

  value = {
    for k, v in var.managed_databases : k => random_password.user[k].result
  }
}
