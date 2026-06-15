inputs = {
  stack = "sdr"

  rtl_tcp = {
    renovate = "docker"
    image    = "ghcr.io/lizenzfass78851/docker-rtl-tcp"
    version  = "latest"
  }

  trunk_recorder = {
    renovate = "docker"
    image    = "robotastic/trunk-recorder"
    version  = "5.2.1"

    # Kenmore PD — conventional P25 (RadioReference: 460.500 MHz, P25, NAC 0xB23).
    # center sits on the one channel for now; the 2.4 MHz window has room to add
    # nearby UHF channels (Fire/DPW/etc.) to `channels` later without retuning.
    source = {
      center = 460500000
    }

    system = {
      short_name = "kenpd"
      type       = "conventionalP25"
      modulation = "fsk4"      # conventional P25 is C4FM
      channels   = [460500000] # 460.500 MHz — Police Ch. 1
      squelch    = -60         # dBm; raise toward -50 if it records noise, lower if it misses calls
    }
  }

  openwebrx = {
    renovate = "docker"
    image    = "docker.io/slechev/openwebrxplus-softmbe"
    version  = "1.2.116"

    receiver = {
      name  = "Leighthaus"
      admin = "owrx@jleight.com"

      location        = "Kenmore, NY"
      country         = "US"
      bandplan_region = 2

      asl = 187
      gps = {
        lat = 42.9615
        lon = -78.8646
      }
    }

    sdrs = {
      rtlsdr = {
        name = "RTL-SDR"
        type = "rtl_tcp"

        profiles = {
          "4985c5f5-1639-4f24-aa8d-4467eeebe094" = {
            name        = "MeshCore"
            center_freq = 910000000
            samp_rate   = 2400000
            start_freq  = 910525000
            start_mod   = "meshcore"
            tuning_step = 1
          }
          adsb1090 = {
            name        = "1090MHz ADSB"
            center_freq = 1090000000
            samp_rate   = 2400000
            start_freq  = 1090000000
            start_mod   = "nfm"
            tuning_step = 25000
          }
          "0ad35577-f34b-4b09-be8e-0ea651ffaa04" = {
            name        = "92.9 FM WBUF"
            center_freq = 92800000
            samp_rate   = 2400000
            start_freq  = 92900000
            start_mod   = "wfm"
            tuning_step = 1
          }
          "571513cf-57c9-48aa-a0c9-749547d17b6d" = {
            name        = "96.9 FM WGRF"
            center_freq = 96800000
            samp_rate   = 2400000
            start_freq  = 96900000
            start_mod   = "wfm"
            tuning_step = 1
          }
          "8d74c121-58c3-49cd-98c5-c197371725f4" = {
            name        = "103.3 FM WEDG"
            center_freq = 103200000
            samp_rate   = 2400000
            start_freq  = 103300000
            start_mod   = "wfm"
            tuning_step = 1
          }
          am = {
            name            = "AM Broadcast"
            center_freq     = 1000000
            samp_rate       = 1024000
            start_freq      = 1200000
            start_mod       = "am"
            tuning_step     = 5000
            direct_sampling = 2
          }
        }
      }
    }
  }
}
