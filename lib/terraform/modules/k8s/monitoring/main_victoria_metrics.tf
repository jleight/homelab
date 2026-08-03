locals {
  victoria_metrics_enabled = local.enabled && var.k8s_monitoring.victoria_metrics.enabled

  scrape_tls_config = {
    ca_file              = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
    insecure_skip_verify = true
  }

  scrape_bearer_token_file = "/var/run/secrets/kubernetes.io/serviceaccount/token"

  # FreeLens' "Helm" metrics provider matches node-level series on a `node` label and
  # kubelet/cadvisor series on the node name in `instance`, neither of which the node
  # and endpoint service discovery roles produce on their own.
  node_role_relabel_configs = [
    {
      source_labels = ["__meta_kubernetes_node_name"]
      target_label  = "node"
    },
    {
      source_labels = ["__meta_kubernetes_node_name"]
      target_label  = "instance"
    }
  ]

  # The chart ships a generic annotation-driven scrape config. These four jobs are all
  # FreeLens actually queries, and pinning them explicitly keeps the label schema under
  # our control instead of whatever annotations happen to be on a Service.
  victoria_metrics_scrape_config = {
    global = {
      scrape_interval = "30s"
    }

    scrape_configs = [
      {
        job_name              = "kubelet"
        scheme                = "https"
        bearer_token_file     = local.scrape_bearer_token_file
        tls_config            = local.scrape_tls_config
        kubernetes_sd_configs = [{ role = "node" }]
        relabel_configs       = local.node_role_relabel_configs
      },
      {
        job_name              = "cadvisor"
        scheme                = "https"
        metrics_path          = "/metrics/cadvisor"
        bearer_token_file     = local.scrape_bearer_token_file
        tls_config            = local.scrape_tls_config
        kubernetes_sd_configs = [{ role = "node" }]
        relabel_configs       = local.node_role_relabel_configs
      },
      {
        job_name = "node-exporter"

        kubernetes_sd_configs = [
          {
            role       = "endpoints"
            namespaces = { names = [local.monitoring_namespace] }
          }
        ]

        relabel_configs = [
          {
            source_labels = ["__meta_kubernetes_service_name"]
            action        = "keep"
            regex         = local.node_exporter_service_name
          },
          {
            source_labels = ["__meta_kubernetes_pod_node_name"]
            target_label  = "node"
          },
          {
            source_labels = ["__meta_kubernetes_pod_node_name"]
            target_label  = "instance"
          }
        ]
      },
      {
        # kube-state-metrics emits its own `node` label describing the object it reports
        # on, not the node it runs on. honor_labels keeps that from being overwritten by
        # the target label, which would make every object look like it lives on one node.
        job_name     = "kube-state-metrics"
        honor_labels = true

        kubernetes_sd_configs = [
          {
            role       = "endpoints"
            namespaces = { names = [local.monitoring_namespace] }
          }
        ]

        relabel_configs = [
          {
            source_labels = ["__meta_kubernetes_service_name"]
            action        = "keep"
            regex         = local.kube_state_metrics_service_name
          }
        ]
      }
    ]
  }
}

resource "helm_release" "victoria_metrics" {
  count = local.victoria_metrics_enabled ? 1 : 0

  namespace  = local.monitoring_namespace
  name       = "victoria-metrics"
  repository = var.k8s_monitoring.victoria_metrics.repository
  chart      = var.k8s_monitoring.victoria_metrics.chart
  version    = var.k8s_monitoring.victoria_metrics.version

  values = [
    yamlencode({
      server = {
        fullnameOverride = "vmsingle"
        retentionPeriod  = var.k8s_monitoring.victoria_metrics.retention_period

        # Metrics here are a live view for FreeLens, not a historical record, so there is
        # nothing worth putting on Longhorn.
        persistentVolume = {
          enabled = false
        }

        # The chart defaults to a headless Service; FreeLens reaches it through the API
        # server's service proxy, which wants a normal ClusterIP.
        service = {
          clusterIP = ""
        }

        scrape = {
          enabled = true
          config  = local.victoria_metrics_scrape_config
        }
      }
    })
  ]
}
