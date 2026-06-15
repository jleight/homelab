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

    # Erie County conventional P25 — every non-encrypted P25 channel that fits in
    # one RTL-SDR's 2.4 MHz window centered on 460.5 MHz (see channels below).
    source = {
      center = 460500000 # window 459.3–461.7 MHz at 2.4 MS/s covers every channel below
      agc    = true      # rtl_tcp can't set a fixed tuner gain; let the tuner auto-gain
    }

    # Two conventional systems sharing the one RTL-SDR window: P25 (digital) and
    # analog FM. Each channel_csv is the in-window, non-encrypted set extracted
    # from the Erie County RadioReference dump; recorder counts are derived from
    # the rows. Disable a channel by setting its Enable column to false, or delete
    # the row, if the 2-core node can't keep up.
    systems = [
      {
        short_name = "ecp25"
        type       = "conventionalP25"
        modulation = "fsk4" # conventional P25 is C4FM
        squelch    = -60    # dBm; raise toward -50 if it records noise, lower if it misses calls

        channel_csv = <<-CSV
        TG Number,Frequency,Tone,Alpha Tag,Description,Tag
        1,460075000,,EC Shrf Patrol,Sheriff Patrol Dispatch,Law Dispatch
        2,460450000,,EC Shrf Ch 2,Sheriff Ch. 2 Jail Transport,Law Tac
        3,460325000,,BPD 1 Car-Car,Police Ch 1 Car to Car,Law Talk
        4,460350000,,BPD 2 Dists B/D,Police Ch 2 Districts B/D,Law Dispatch
        5,460425000,,BPD 3 Dists C/E,Police Ch 3 Districts C/E,Law Dispatch
        6,460475000,,BPD 4 Dist A,Police Ch 4 District A,Law Dispatch
        7,460025000,,BPD 5 Warrants,Police Ch 5 Information and Warrant Checks,Law Tac
        8,460437500,,T/Hamburg PD Dsp,Police Dispatch,Law Dispatch
        9,460500000,,Kenmore PD,Police Ch. 1,Law Dispatch
        10,460225000,,TPD 1 Disp,City Police Dispatch,Law Dispatch
        11,460100000,,Tonawanda PD,Police Dispatch,Law Dispatch
        CSV
      },
      {
        short_name = "ecfm"
        type       = "conventional" # analog FM
        squelch    = -60

        channel_csv = <<-CSV
        TG Number,Frequency,Tone,Alpha Tag,Description,Tag
        1,460275000,,EC CW Police UHF,Countywide Police UHF,Law Dispatch
        2,460050000,,EC Holding Cntr,Holding Center,Corrections
        3,460400000,,EC CW Fire,Countywide Fire,Fire Dispatch
        6,461412500,,M-T FD 461,Main-Transit Fire Department,Fire-Tac
        22,460012500,,TPD 2 Sp Ops,Police Special Operations,Law Tac
        23,460600000,,TonwndaFDisp,City Fire Dispatch,Fire Dispatch
        24,460087500,,TonawandaCh2,City Fire Ch. 2,Fire-Tac
        25,460975000,,Tonawnda FD 1,Fire Ch 1,Fire Dispatch
        26,460900000,,Tonawnda FD 2,Fire Ch 2,Fire-Tac
        CSV
      }
    ]
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
