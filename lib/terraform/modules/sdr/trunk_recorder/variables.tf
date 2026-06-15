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

    # The RF window one RTL-SDR samples. Every channel Trunk Recorder records
    # must fall within center ± rate/2, and rate is capped by what rtl_tcp can
    # stream (~2.4 MS/s for an RTL-SDR). All user-specific, from RadioReference +
    # your dongle. digital_recorders must be >= the number of conventional
    # channels (each gets a dedicated always-on recorder).
    source = object({
      center            = number # Hz, midpoint of the channels you need
      rate              = optional(number, 2400000)
      gain              = optional(number, 39)
      error             = optional(number, 0) # ppm/freq correction for the dongle
      digital_recorders = optional(number, 4)
    })

    # The system to follow, from its RadioReference page.
    #
    # type: "conventionalP25" (fixed channels, "RM"/"RF" rows) or "p25" (trunked,
    # with a control channel). modulation: "fsk4" for Phase 1 C4FM (most
    # conventional), "qpsk" for P25 Phase 2 / LSM simulcast.
    #
    # Conventional uses `channels` + `squelch` (channels aren't always keyed up,
    # so squelch gates recording to actual activity). Trunked uses
    # `control_channels`. Set whichever pair matches `type`.
    system = object({
      short_name = string
      type       = optional(string, "conventionalP25")
      modulation = optional(string, "fsk4")

      channels = optional(list(number), []) # conventional: fixed freqs (Hz)
      squelch  = optional(number, -60)      # conventional: dBm threshold

      control_channels = optional(list(number), []) # trunked: control freqs (Hz)
    })

    # Optional RadioReference talkgroup CSV (raw contents). Empty = record all
    # talkgroups and leave them unlabelled.
    talkgroups_csv = optional(string, "")
  })
}
