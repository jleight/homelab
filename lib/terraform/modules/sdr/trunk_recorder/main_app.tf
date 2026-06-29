# Trunk Recorder follows a P25 control channel and records calls to disk off its
# own dedicated RTL-SDR (the sdr-trunk dongle, claimed directly via the device
# plugin). The stock image CMD already runs
# `trunk-recorder --config=/app/config.json`, so no command override is needed.
module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = var.namespace

  image         = var.trunk_recorder.image
  image_version = var.trunk_recorder.version

  # Local time so the date-based recording folders match the audio player's
  # (and your) timezone instead of UTC.
  env = {
    TZ = var.trunk_recorder.timezone
  }

  # Outbound-only daemon: it reads from the local dongle and (later) dials an
  # uploader; it listens on nothing, so no container port and no Service.
  create_service  = false
  ingress_enabled = false

  # Holds the sdr-trunk dongle exclusively; Recreate prevents a rollout from
  # briefly running two pods that both try to grab the one device.
  deployment_strategy = "Recreate"

  # Requesting the device-plugin resource pins the pod to the node with the
  # sdr-trunk dongle attached and mounts the matching /dev/bus/usb node in with
  # the right cgroup permissions. Kubernetes mirrors extended-resource limits
  # into requests.
  resource_limits = {
    (var.trunk_recorder.device_resource) = "1"
  }

  # ConfigMap content changes don't alter the pod template; hash all config files
  # (config.json + channelFiles) into an annotation so editing any of them in
  # stack.hcl rolls the pod.
  pod_annotations = {
    "checksum/config" = sha256(jsonencode(local.config_files))
  }

  volumes_from_config_maps = {
    config = local.config_cm
  }

  # Recordings land on the Media SMB share (RWX) under its `radio` subfolder, so
  # they're browsable alongside the rest of the NAS media rather than trapped on
  # a cluster-local volume.
  persistent_volume_claims = {
    media = {
      storage_class = var.media_storage_class
      storage_size  = "10Ti"
    }
  }

  volume_mounts = concat(
    [
      {
        name       = "config"
        mount_path = "/app/config.json"
        sub_path   = "config.json"
        read_only  = true
      }
    ],
    [
      for s in var.trunk_recorder.systems :
      {
        name       = "config"
        mount_path = "/app/${s.short_name}.csv"
        sub_path   = "${s.short_name}.csv"
        read_only  = true
      }
    ],
    [
      {
        name       = "media"
        mount_path = "/app/media"
        sub_path   = "radio"
        read_only  = false
      }
    ]
  )
}
