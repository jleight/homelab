resource "helm_release" "intel_gpu" {
  count = local.enabled ? 1 : 0

  namespace  = "kube-system"
  name       = "intel-gpu"
  repository = var.k8s_baseline.intel_gpu.repository
  chart      = var.k8s_baseline.intel_gpu.chart
  version    = var.k8s_baseline.intel_gpu.version

  set = [
    {
      name  = "manager.devices.gpu"
      value = "true"
    }
  ]
}

resource "kubectl_manifest" "intel_gpu_device_plugin" {
  yaml_body = yamlencode({
    apiVersion = "deviceplugin.intel.com/v1"
    kind       = "GpuDevicePlugin"

    metadata = {
      namespace = "kube-system"
      name      = "gpudeviceplugin"
    }

    spec = {
      image = "intel/intel-gpu-plugin:${var.k8s_baseline.intel_gpu.version}"

      sharedDevNum = 1
      logLevel     = 4

      preferredAllocationPolicy = "none"

      nodeSelector = {
        "feature.node.kubernetes.io/pci-0300_8086.present" = "true"
      }
    }
  })
}
