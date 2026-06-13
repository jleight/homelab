# Turnstone server nodes: a fleet of workers that run agent workstreams. A
# StatefulSet (not app_deployment, which is for singleton services) gives each
# node a stable ordinal identity and, via the headless Service below, stable
# per-pod DNS — which is what the console needs to address and reverse-proxy into
# each node. Scale the fleet with var.turnstone.server_count. Nodes are never
# exposed externally; each registers itself in the console-owned `services` table
# (TURNSTONE_NODE_ID + TURNSTONE_ADVERTISE_URL) and the console discovers it. The
# image entrypoint runs DB migrations on boot (idempotent across nodes).

locals {
  server_labels = {
    "app.kubernetes.io/name"      = local.server_name
    "app.kubernetes.io/component" = "server"
  }
}

# Headless Service — gives each StatefulSet pod stable DNS at
# <pod>.<service>.<namespace>.svc.cluster.local. ClusterIP "None", no external
# exposure; it's the in-cluster addressing the console proxies to.
resource "kubernetes_service_v1" "server" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = local.server_name
    labels    = local.server_labels
  }

  spec {
    cluster_ip                  = "None"
    publish_not_ready_addresses = true
    selector                    = local.server_labels

    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }
  }
}

resource "kubernetes_stateful_set_v1" "server" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = local.server_name
    labels    = local.server_labels
  }

  spec {
    replicas     = var.turnstone.server_count
    service_name = local.server_name

    selector {
      match_labels = local.server_labels
    }

    template {
      metadata {
        labels = local.server_labels
      }

      spec {
        # /data (the image WORKDIR, where agent file operations land) is a
        # per-pod volume below; the container runs as the unprivileged
        # `turnstone` user (uid 1000), so fsGroup makes the kubelet chown it.
        security_context {
          fs_group = 1000
        }

        container {
          name  = "server"
          image = "${var.turnstone.image}:${var.turnstone.version}"

          # LLM backend is a boot-time default passed as CLI flags (real backends
          # can also be added later in the console Models tab). Lemonade is
          # keyless, so the api-key is a placeholder.
          args = [
            "turnstone-server",
            "--host=0.0.0.0",
            "--port=8080",
            "--base-url=${var.turnstone.llm_base_url}",
            "--api-key=dummy"
          ]

          port {
            container_port = 8080
          }

          # Pod name (= stable StatefulSet ordinal, e.g. server-0) drives both
          # the node identity and the advertised per-pod DNS the console reaches
          # it at. POD_NAME must precede the env vars that reference $(POD_NAME).
          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name  = "TURNSTONE_NODE_ID"
            value = "$(POD_NAME)"
          }

          env {
            name  = "TURNSTONE_ADVERTISE_URL"
            value = "http://$(POD_NAME).${local.server_name}.${local.namespace}.svc.cluster.local:8080"
          }

          env {
            name  = "TURNSTONE_DB_BACKEND"
            value = "postgresql"
          }

          # web_search backend — the bundled SearxNG (see main_searxng.tf).
          # Local/vLLM models route web_search here; commercial providers use
          # their own native search and never hit it.
          env {
            name  = "TURNSTONE_SEARXNG_URL"
            value = local.searxng_url
          }

          # Shared JWT secret (so the console's service tokens authenticate here)
          # and the console-owned cluster database the node registers into.
          env {
            name = "TURNSTONE_JWT_SECRET"
            value_from {
              secret_key_ref {
                name = local.jwt_secret_name
                key  = "TURNSTONE_JWT_SECRET"
              }
            }
          }

          env {
            name = "TURNSTONE_DB_URL"
            value_from {
              secret_key_ref {
                name = module.console.postgres_secret_name
                key  = "url"
              }
            }
          }

          volume_mount {
            name       = "data"
            mount_path = "/data"
          }

          volume_mount {
            name       = "workspace"
            mount_path = "/workspace"
          }
        }

        # Per-pod ephemeral scratch. Turnstone coordinates through Postgres, not
        # the filesystem, and each workstream is pinned to the node it runs on —
        # so nodes don't need to share these, and they hold no durable state
        # (that lives in the DB). emptyDir avoids both a PVC and the RWX
        # share-manager a genuinely shared volume would pull in. fsGroup (above)
        # makes them writable by the non-root turnstone user.
        volume {
          name = "data"
          empty_dir {
            size_limit = var.turnstone.scratch_size_limit
          }
        }

        volume {
          name = "workspace"
          empty_dir {
            size_limit = var.turnstone.scratch_size_limit
          }
        }
      }
    }
  }
}
