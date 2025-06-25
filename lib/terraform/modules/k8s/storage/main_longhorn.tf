locals {
  longhorn_enabled = local.enabled && var.k8s_storage.longhorn.enabled

  longhorn_nas02_credentials_name = local.longhorn_enabled ? kubernetes_secret.longhorn_nas02_credentials[0].metadata[0].name : null
}

resource "kubernetes_namespace" "longhorn" {
  count = local.longhorn_enabled ? 1 : 0

  metadata {
    name = "longhorn-system"

    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

resource "kubernetes_secret" "longhorn_nas02_credentials" {
  count = local.longhorn_enabled ? 1 : 0

  metadata {
    namespace = try(one(kubernetes_namespace.longhorn[0].metadata).name, null)
    name      = "smb-nas02-credentials"
  }

  data = {
    CIFS_USERNAME = var.smb_nas02_username
    CIFS_PASSWORD = var.smb_nas02_password
  }
}

resource "helm_release" "longhorn" {
  count = local.longhorn_enabled ? 1 : 0

  namespace  = try(one(kubernetes_namespace.longhorn[0].metadata).name, null)
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
    }
  ]
}

resource "kubernetes_storage_class" "longhorn_appdata" {
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

  depends_on = [helm_release.openebs]
}

resource "kubectl_manifest" "longhorn_backup_daily" {
  count = local.longhorn_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "longhorn.io/v1beta2"
    kind       = "RecurringJob"

    metadata = {
      namespace = try(one(kubernetes_namespace.longhorn[0].metadata).name, null)
      name      = "daily"
    }

    spec = {
      name = "daily"
      cron = "30 8 * * *"
      task = "backup"

      retain      = 28
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

resource "kubectl_manifest" "longhorn_backup_monthly" {
  count = local.longhorn_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "longhorn.io/v1beta2"
    kind       = "RecurringJob"

    metadata = {
      namespace = try(one(kubernetes_namespace.longhorn[0].metadata).name, null)
      name      = "monthly"
    }

    spec = {
      name = "monthly"
      cron = "30 10 1 * *"
      task = "backup"

      retain      = 12
      concurrency = 2

      groups = ["default"]
      labels = { type = "monthly" }

      parameters = {
        full-backup-interval = "0"
      }
    }
  })

  depends_on = [helm_release.longhorn]
}
