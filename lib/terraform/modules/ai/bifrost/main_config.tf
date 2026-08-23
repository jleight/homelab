locals {
  # Secrets are never written into config.json. Bifrost resolves any value with
  # an "env." prefix from the process environment at startup, so the file stays
  # a plain ConfigMap and the real values come from the Secret above.
  #
  # Both stores go to the stack-level Postgres rather than the default SQLite in
  # the app directory: logs_store is write-heavy, and write-heavy SQLite on
  # replicated storage is exactly what corrupted the *arr databases.
  #
  # Only the password comes through env -- host/db/user are not secret, and
  # inlining them keeps config.json readable as the source of truth.
  postgres_store = {
    enabled = true
    type    = "postgres"

    config = {
      host     = var.db_host
      port     = tostring(var.db_port)
      user     = var.db_username
      password = "env.PG_PASSWORD"
      db_name  = var.db_name
      ssl_mode = "require"
    }
  }

  bifrost_config = {
    encryption_key = "env.BIFROST_ENCRYPTION_KEY"

    client = {
      enforce_auth_on_inference = true

      # Bifrost's onboarding checklist asks for this; seeding it here means the
      # dashboard ships already configured. Only the gateway's own origin is
      # allowed by default, which is all the bundled UI needs -- CORS is a
      # browser-side control, so API clients are unaffected either way.
      allowed_origins = concat(
        ["https://${local.hostname}"],
        var.bifrost.extra_allowed_origins
      )
    }

    config_store = local.postgres_store
    logs_store   = local.postgres_store

    providers = {
      lemonade = {
        # A custom provider is just a renamed base type: the wire format is
        # still OpenAI's, but calls address it as "lemonade/<model>" instead of
        # "openai/<model>". is_key_less is deliberately NOT set -- it skips key
        # registration, which leaves the key unhealthy and unroutable.
        custom_provider_config = {
          base_provider_type = "openai"
        }

        network_config = {
          base_url = var.bifrost.lemonade.url

          # Bifrost refuses to dial RFC1918 destinations unless this is set, and
          # Lemonade lives on the LAN. Without it every request fails at the
          # transport with a bare "failed to execute HTTP request", and the
          # startup list-models probe marks the key unhealthy, which takes the
          # provider out of routing entirely.
          allow_private_network = true

          default_request_timeout_in_seconds = var.bifrost.request_timeout_seconds
          stream_idle_timeout_in_seconds     = var.bifrost.stream_idle_timeout_seconds
        }

        # Lemonade holds one model resident at a time and swaps on demand, so
        # concurrency is capped at 1: a second in-flight request would only
        # thrash the 30GB of weights back out of memory.
        concurrency_and_buffer_size = {
          concurrency = 1
          buffer_size = 16
        }

        keys = [
          {
            name   = "lemonade"
            value  = var.bifrost.lemonade.api_key
            models = ["*"]
            weight = 1.0
          }
        ]
      }
    }

    # Only admin auth is declared here. Virtual keys are created by hand in the
    # dashboard, so "virtual_keys" is deliberately absent rather than an empty
    # list: omitting the sub-section leaves stored keys alone, whereas an empty
    # array is the signal to delete them. Do not "tidy" this into `[]`.
    #
    # enforce_auth_on_inference above still applies, so the gateway fails closed
    # until at least one key exists.
    governance = {
      auth_config = {
        is_enabled                = true
        admin_username            = "env.BIFROST_ADMIN_USERNAME"
        admin_password            = "env.BIFROST_ADMIN_PASSWORD"
        disable_auth_on_inference = false
      }
    }
  }
}

resource "kubernetes_config_map_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = "${local.name}-config"
  }

  data = {
    "config.json" = jsonencode(local.bifrost_config)
  }
}
