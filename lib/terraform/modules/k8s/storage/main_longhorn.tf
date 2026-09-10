locals {
  longhorn_enabled = local.enabled && var.k8s_storage.longhorn.enabled

  longhorn_nas02_credentials_name = local.longhorn_enabled ? kubernetes_secret_v1.longhorn_nas02_credentials[0].metadata[0].name : null
}

resource "kubernetes_namespace_v1" "longhorn" {
  count = local.longhorn_enabled ? 1 : 0

  metadata {
    name = "longhorn-system"

    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

resource "kubernetes_secret_v1" "longhorn_nas02_credentials" {
  count = local.longhorn_enabled ? 1 : 0

  metadata {
    namespace = try(one(kubernetes_namespace_v1.longhorn[0].metadata).name, null)
    name      = "smb-nas02-credentials"
  }

  data = {
    CIFS_USERNAME = var.smb_nas02_username
    CIFS_PASSWORD = var.smb_nas02_password
  }
}

resource "helm_release" "longhorn" {
  count = local.longhorn_enabled ? 1 : 0

  namespace  = try(one(kubernetes_namespace_v1.longhorn[0].metadata).name, null)
  name       = "longhorn"
  repository = var.k8s_storage.longhorn.repository
  chart      = var.k8s_storage.longhorn.chart
  version    = var.k8s_storage.longhorn.version

  set = [
    {
      name  = "defaultBackupStore.backupTarget"
      value = "cifs:${var.smb_nas02_url}/${local.stack}_${local.environment}_backup"
    },
    {
      name  = "defaultBackupStore.backupTargetCredentialSecret"
      value = local.longhorn_nas02_credentials_name
    },
    {
      name  = "defaultSettings.defaultDataPath"
      value = "/var/mnt/longhorn"
    },
    {
      name  = "defaultSettings.concurrentAutomaticEngineUpgradePerNodeLimit"
      value = "3"
      type  = "string"
    },
    {
      name  = "defaultSettings.engineReplicaTimeout"
      value = "20"
      type  = "string"
    },
    {
      name  = "defaultSettings.defaultBackupBlockSize"
      value = "16"
      type  = "string"
    }
  ]
}

resource "kubernetes_storage_class_v1" "longhorn_appdata" {
  count = local.longhorn_enabled ? 1 : 0

  metadata {
    name = "longhorn-appdata"
  }

  storage_provisioner = "driver.longhorn.io"

  volume_binding_mode    = "Immediate"
  reclaim_policy         = "Retain"
  allow_volume_expansion = true

  parameters = {
    "numberOfReplicas"    = "3"
    "staleReplicaTimeout" = "30"
    "dataLocality"        = "best-effort"
    "replicaAutoBalance"  = "least-effort"
  }

  depends_on = [helm_release.longhorn]
}

# Single-replica, strict-local Longhorn storage class for throwaway scratch
# space (e.g. CI pipeline workspaces). Unlike the other classes this reclaims on
# delete, so dynamically-provisioned volumes are cleaned up when their PVC goes
# away rather than piling up as Released PVs.
resource "kubernetes_storage_class_v1" "longhorn_ephemeral" {
  count = local.longhorn_enabled ? 1 : 0

  metadata {
    name = "longhorn-ephemeral"
  }

  storage_provisioner = "driver.longhorn.io"

  volume_binding_mode    = "WaitForFirstConsumer"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true

  parameters = {
    "numberOfReplicas"    = "1"
    "staleReplicaTimeout" = "30"
    "dataLocality"        = "strict-local"

    # Assign these volumes to a dedicated "ephemeral" group, which no recurring
    # job targets. Carrying any recurring-job label excludes a volume from the
    # implicit "default" group that the daily/weekly/monthly backup jobs run
    # against, so scratch data is never backed up (and nothing else is scheduled
    # against it).
    "recurringJobSelector" = jsonencode([
      {
        name    = "ephemeral"
        isGroup = true
      }
    ])
  }

  depends_on = [helm_release.longhorn]
}

# Grandfather-father-son backup tiering: a week of dailies, a month of weeklies,
# a year of monthlies. Depth is what drives the size of the backupstore -- the
# high-churn Postgres volumes rewrite ~30% of their blocks every day, so each
# extra daily restore point costs nearly a full copy of their block set.
#
# Crons are UTC -- Longhorn's validating webhook parses exactly 5 fields and
# rejects a CRON_TZ prefix. Monthly, then weekly, then daily land at
# 03:00/03:30/04:00 America/New_York in summer and an hour earlier in winter.
# Coarsest first is deliberate: whatever runs first cannot be blocked by an
# earlier job overrunning, and a missed monthly leaves a permanent hole in the
# year of history where a missed daily is replaced tomorrow. They all have to
# finish before the cloud sync starts (04:30 device-local), or it walks the
# backupstore while retention deletes blocks underneath it. A sweep takes 5
# minutes, or 10 on the every-seventh-run full backup below, against 30-minute
# spacing -- so it holds in both seasons even when all three fire.
resource "kubectl_manifest" "longhorn_backup_daily" {
  count = local.longhorn_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "longhorn.io/v1beta2"
    kind       = "RecurringJob"

    metadata = {
      namespace = try(one(kubernetes_namespace_v1.longhorn[0].metadata).name, null)
      name      = "daily"
    }

    spec = {
      name = "daily"
      cron = "0 8 * * *"
      task = "backup"

      retain      = 7
      concurrency = 2

      groups = ["default"]
      labels = { type = "daily" }

      parameters = {
        full-backup-interval = "7"
      }
    }
  })

  depends_on = [helm_release.longhorn]
}

resource "kubectl_manifest" "longhorn_backup_weekly" {
  count = local.longhorn_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "longhorn.io/v1beta2"
    kind       = "RecurringJob"

    metadata = {
      namespace = try(one(kubernetes_namespace_v1.longhorn[0].metadata).name, null)
      name      = "weekly"
    }

    spec = {
      name = "weekly"
      cron = "30 7 * * 0"
      task = "backup"

      retain      = 4
      concurrency = 2

      groups = ["default"]
      labels = { type = "weekly" }

      parameters = {
        "full-backup-interval" = "0"
      }
    }
  })

  depends_on = [helm_release.longhorn]
}

resource "kubectl_manifest" "longhorn_backup_monthly" {
  count = local.longhorn_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "longhorn.io/v1beta2"
    kind       = "RecurringJob"

    metadata = {
      namespace = try(one(kubernetes_namespace_v1.longhorn[0].metadata).name, null)
      name      = "monthly"
    }

    spec = {
      name = "monthly"
      cron = "0 7 1 * *"
      task = "backup"

      retain      = 12
      concurrency = 2

      groups = ["default"]
      labels = { type = "monthly" }

      parameters = {
        "full-backup-interval" = "0"
      }
    }
  })

  depends_on = [helm_release.longhorn]
}

resource "kubectl_manifest" "longhorn_ingress" {
  count = local.longhorn_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"

    metadata = {
      namespace = try(one(kubernetes_namespace_v1.longhorn[0].metadata).name, null)
      name      = "longhorn-frontend"
    }

    spec = {
      parentRefs = var.gateway_refs
      hostnames  = ["longhorn.${var.gateway_domain}"]
      rules = [
        {
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = "/"
              }
            }
          ]
          backendRefs = [
            {
              name = "longhorn-frontend"
              port = 80
            }
          ]
        }
      ]
    }
  })

  depends_on = [helm_release.longhorn]
}
