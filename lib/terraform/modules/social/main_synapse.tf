locals {
  # Matrix IDs use the bare gateway domain (@user:leightha.us); clients find
  # the homeserver itself via the web stack's /.well-known/matrix/client.
  synapse_server_name = var.synapse.gateway_domain
  synapse_domain      = "${var.synapse.subdomain}.${var.synapse.gateway_domain}"
  synapse_db          = module.database_cluster.databases["synapse"]
}

resource "random_password" "synapse_registration_shared_secret" {
  length  = 64
  special = false
}

resource "random_password" "synapse_macaroon_secret_key" {
  length  = 64
  special = false
}

resource "random_password" "synapse_form_secret" {
  length  = 64
  special = false
}

# Synapse's signing key file is `ed25519 <key id> <unpadded base64 seed>`.
resource "random_bytes" "synapse_signing_key" {
  length = 32
}

resource "random_string" "synapse_signing_key_id" {
  length  = 6
  special = false
  upper   = false
}

# Synapse merges multiple --config-path files at the top level, so everything
# secret (including the whole database block) lives in this second file.
resource "kubernetes_secret_v1" "synapse" {
  metadata {
    namespace = module.namespace.name
    name      = "synapse"
  }

  data = {
    "secrets.yaml" = yamlencode({
      registration_shared_secret = random_password.synapse_registration_shared_secret.result
      macaroon_secret_key        = random_password.synapse_macaroon_secret_key.result
      form_secret                = random_password.synapse_form_secret.result

      database = {
        name = "psycopg2"
        args = {
          host     = module.database_cluster.host
          port     = module.database_cluster.port
          dbname   = local.synapse_db.database
          user     = local.synapse_db.username
          password = module.database_cluster.passwords["synapse"]
          cp_min   = 5
          cp_max   = 10
        }
      }
    })

    "signing.key" = "ed25519 a_${random_string.synapse_signing_key_id.result} ${trimsuffix(random_bytes.synapse_signing_key.base64, "=")}"
  }
}

# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "synapse_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "synapse-subst"
  }

  data = {
    media_storage_class = var.synapse.media_storage_class
    gateway_parent_refs = jsonencode(var.synapse.gateway_refs)
    domain              = local.synapse_domain
    server_name         = local.synapse_server_name
  }
}
