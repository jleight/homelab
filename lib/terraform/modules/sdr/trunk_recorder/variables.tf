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

variable "rtl_tcp_host" {
  description = "In-cluster hostname of the rtl_tcp server Trunk Recorder pulls IQ from."
  type        = string
}

variable "rtl_tcp_port" {
  description = "Port of the rtl_tcp server."
  type        = number
}

variable "trunk_recorder" {
  description = "Trunk Recorder configuration."
  type = object({
    image   = string
    version = string

    timezone = optional(string, "UTC")

    # The RF window one RTL-SDR samples. Every channel across all systems must
    # fall within center ± rate/2, and rate is capped by what rtl_tcp can stream
    # (~2.4 MS/s for an RTL-SDR). The recorder counts are derived from the
    # channel CSVs, so they don't need setting here.
    source = object({
      center = number # Hz, midpoint of the channels you want
      rate   = optional(number, 2400000)
      gain   = optional(number, 39)

      # Over rtl_tcp, gr-osmosdr can't enumerate the tuner's discrete gain steps,
      # so a fixed `gain` gets clamped to 0 (deaf). AGC lets the tuner auto-gain
      # instead — the mode OpenWebRX uses successfully against this rtl_tcp server.
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
