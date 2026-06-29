variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy into."
  type        = string
}

variable "media_storage_class" {
  description = "StorageClass for the Media SMB share; recordings land in its `radio` subfolder."
  type        = string
}

variable "trunk_recorder" {
  description = "Trunk Recorder configuration."
  type = object({
    image   = string
    version = string

    timezone = optional(string, "UTC")

    # Generic-device-plugin resource for the dongle Trunk Recorder claims
    # exclusively (a NooElec SMArt XTR v5 dedicated to scanning). Requesting it
    # pins the pod to the node with that dongle and mounts only its /dev/bus/usb
    # node in, so osmosdr finds it as the sole rtl device.
    device_resource = optional(string, "devices.k8s.leightha.us/sdr-trunk")

    # The RF window the RTL-SDR samples. Every channel across all systems must
    # fall within center ± rate/2, and rate is capped by what an RTL-SDR can
    # sustain (~2.4 MS/s). The recorder counts are derived from the channel CSVs,
    # so they don't need setting here.
    source = object({
      center = number # Hz, midpoint of the channels you want
      rate   = optional(number, 2400000)
      gain   = optional(number, 39)

      # The dongle is claimed directly over USB (not via rtl_tcp), so osmosdr can
      # enumerate the tuner's discrete gain steps and a fixed `gain` works as
      # expected. AGC is available as an alternative but off by default.
      agc   = optional(bool, false)
      error = optional(number, 0) # ppm/freq correction for the dongle
    })

    # One or more conventional systems sharing the source. `type` is
    # "conventionalP25" (set modulation "fsk4"/"qpsk") or "conventional" (analog
    # FM, no modulation). `channel_csv` is a Trunk Recorder channelFile: a header
    # row (TG Number,Frequency,Tone,Alpha Tag,Description,Tag) then one row per
    # channel. The number of always-on recorders the source needs is derived from
    # the total rows per system type.
    systems = list(object({
      short_name  = string
      type        = string
      modulation  = optional(string)
      squelch     = optional(number, -60)
      channel_csv = string
    }))
  })
}
