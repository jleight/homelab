inputs = {
  stack = "sdr"

  audioplayer = {
    renovate = "docker"
    image    = "php"
    version  = "8.5-apache"

    timezone = "UTC"
  }

  dump978 = {
    renovate = "docker"
    image    = "ghcr.io/sdr-enthusiasts/docker-dump978"
    version  = "latest"

    replicas = 0
  }

  openwebrx = {
    renovate = "docker"
    image    = "docker.io/slechev/openwebrxplus-softmbe"
    version  = "1.2.117"

    receiver = {
      name  = "Leighthaus"
      admin = "owrx@jleight.com"

      location        = "Kenmore, NY"
      country         = "US"
      bandplan_region = 2

      asl = 187
      gps = {
        lat = 42.961356
        lon = -78.868374
      }
    }

    sdrs = {
      rtlsdr = {
        name = "RTL-SDR"
        type = "rtl_tcp"

        profiles = {
          "FM-92.9" = {
            name        = "92.9 FM WBUF"
            center_freq = 92800000
            samp_rate   = 2400000
            start_freq  = 92900000
            start_mod   = "wfm"
            tuning_step = 1
          }
          "FM-96.9" = {
            name        = "96.9 FM WGRF"
            center_freq = 96800000
            samp_rate   = 2400000
            start_freq  = 96900000
            start_mod   = "wfm"
            tuning_step = 1
          }
          "FM-103.3" = {
            name        = "103.3 FM WEDG"
            center_freq = 103200000
            samp_rate   = 2400000
            start_freq  = 103300000
            start_mod   = "wfm"
            tuning_step = 1
          }
          "AM" = {
            name        = "AM Broadcast"
            center_freq = 1000000
            samp_rate   = 1024000
            start_freq  = 1200000
            start_mod   = "am"
            tuning_step = 5000
          }

          # HF amateur bands (region 2). The V4 tunes these natively off the
          # 100 kHz–180 MHz active loop. samp_rate is sized to cover each band in
          # one window (1.2 MS/s for the narrow bands, 2.4 MS/s for the wide 10 m);
          # default mode follows the region-2 convention — LSB below 10 MHz, USB
          # above, CW on the CW/digital-only bands.
          "HF-160m" = {
            name        = "160m"
            center_freq = 1900000
            samp_rate   = 1200000
            start_freq  = 1900000
            start_mod   = "lsb"
            tuning_step = 1000
          }
          "HF-80m" = {
            name        = "80m"
            center_freq = 3700000
            samp_rate   = 1200000
            start_freq  = 3800000
            start_mod   = "lsb"
            tuning_step = 1000
          }
          "HF-40m" = {
            name        = "40m"
            center_freq = 7150000
            samp_rate   = 1200000
            start_freq  = 7175000
            start_mod   = "lsb"
            tuning_step = 1000
          }
          "HF-30m" = {
            name        = "30m"
            center_freq = 10125000
            samp_rate   = 1200000
            start_freq  = 10130000
            start_mod   = "cw"
            tuning_step = 100
          }
          "HF-20m" = {
            name        = "20m"
            center_freq = 14150000
            samp_rate   = 1200000
            start_freq  = 14200000
            start_mod   = "usb"
            tuning_step = 1000
          }
          "HF-17m" = {
            name        = "17m"
            center_freq = 18118000
            samp_rate   = 1200000
            start_freq  = 18130000
            start_mod   = "usb"
            tuning_step = 1000
          }
          "HF-15m" = {
            name        = "15m"
            center_freq = 21225000
            samp_rate   = 1200000
            start_freq  = 21300000
            start_mod   = "usb"
            tuning_step = 1000
          }
          "HF-12m" = {
            name        = "12m"
            center_freq = 24940000
            samp_rate   = 1200000
            start_freq  = 24950000
            start_mod   = "usb"
            tuning_step = 1000
          }
          "HF-10m" = {
            name        = "10m"
            center_freq = 28850000
            samp_rate   = 2400000
            start_freq  = 28400000
            start_mod   = "usb"
            tuning_step = 1000
          }

          # General-interest bands spanning the loop's 100 kHz–180 MHz range, for
          # hopping around to see what's active. Names carry the frequency range
          # and signal type since they're for exploring. Shortwave broadcast and
          # NDBs are AM; airband is AM; VHF voice (weather/marine/2 m) is narrow
          # FM; 6 m is SSB.
          "NDB" = {
            name        = "LF NDB Beacons (200–500 kHz)"
            center_freq = 360000
            samp_rate   = 250000
            start_freq  = 360000
            start_mod   = "am"
            tuning_step = 1000
          }
          "SW-49m" = {
            name        = "49m SW Broadcast (5.9–6.2 MHz)"
            center_freq = 6050000
            samp_rate   = 1200000
            start_freq  = 6000000
            start_mod   = "am"
            tuning_step = 5000
          }
          "SW-41m" = {
            name        = "41m SW Broadcast (7.2–7.45 MHz)"
            center_freq = 7325000
            samp_rate   = 1200000
            start_freq  = 7300000
            start_mod   = "am"
            tuning_step = 5000
          }
          "SW-31m" = {
            name        = "31m SW Broadcast (9.4–9.9 MHz)"
            center_freq = 9650000
            samp_rate   = 1200000
            start_freq  = 9600000
            start_mod   = "am"
            tuning_step = 5000
          }
          "SW-25m" = {
            name        = "25m SW Broadcast (11.6–12.1 MHz)"
            center_freq = 11850000
            samp_rate   = 1200000
            start_freq  = 11800000
            start_mod   = "am"
            tuning_step = 5000
          }
          "SW-19m" = {
            name        = "19m SW Broadcast (15.1–15.8 MHz)"
            center_freq = 15450000
            samp_rate   = 1200000
            start_freq  = 15400000
            start_mod   = "am"
            tuning_step = 5000
          }
          "WWV" = {
            name        = "WWV Time Signal (10 MHz)"
            center_freq = 10000000
            samp_rate   = 1200000
            start_freq  = 10000000
            start_mod   = "am"
            tuning_step = 1000
          }
          "CB" = {
            name        = "CB / 11m (26.965–27.405 MHz)"
            center_freq = 27200000
            samp_rate   = 1200000
            start_freq  = 27185000
            start_mod   = "am"
            tuning_step = 5000
          }
          "VHF-6m" = {
            name        = "6m Ham (50–54 MHz)"
            center_freq = 50300000
            samp_rate   = 1200000
            start_freq  = 50125000
            start_mod   = "usb"
            tuning_step = 1000
          }
          "Airband" = {
            name        = "Airband / Aircraft (118–137 MHz)"
            center_freq = 125000000
            samp_rate   = 2400000
            start_freq  = 124000000
            start_mod   = "am"
            tuning_step = 25000
          }
          "VHF-2m" = {
            name        = "2m Ham FM (144–148 MHz)"
            center_freq = 146000000
            samp_rate   = 2400000
            start_freq  = 146520000
            start_mod   = "nfm"
            tuning_step = 5000
          }
          "Weather" = {
            name        = "NOAA Weather Radio (162 MHz)"
            center_freq = 162475000
            samp_rate   = 1200000
            start_freq  = 162550000
            start_mod   = "nfm"
            tuning_step = 25000
          }
          "Marine" = {
            name        = "Marine VHF (156–162 MHz)"
            center_freq = 157000000
            samp_rate   = 2400000
            start_freq  = 156800000
            start_mod   = "nfm"
            tuning_step = 25000
          }

          # Digital modes on their standard USB dial frequencies, with OpenWebRX's
          # built-in decoder selected as the start mode. Narrow windows (250 kHz)
          # since each only needs its ~3 kHz segment. FT8 is the busiest digital
          # mode; WSPR is propagation beacons. Bands chosen for the most activity.
          "FT8-40m" = {
            name        = "FT8 40m (7.074 MHz)"
            center_freq = 7074000
            samp_rate   = 250000
            start_freq  = 7074000
            start_mod   = "ft8"
            tuning_step = 100
          }
          "FT8-30m" = {
            name        = "FT8 30m (10.136 MHz)"
            center_freq = 10136000
            samp_rate   = 250000
            start_freq  = 10136000
            start_mod   = "ft8"
            tuning_step = 100
          }
          "FT8-20m" = {
            name        = "FT8 20m (14.074 MHz)"
            center_freq = 14074000
            samp_rate   = 250000
            start_freq  = 14074000
            start_mod   = "ft8"
            tuning_step = 100
          }
          "FT8-15m" = {
            name        = "FT8 15m (21.074 MHz)"
            center_freq = 21074000
            samp_rate   = 250000
            start_freq  = 21074000
            start_mod   = "ft8"
            tuning_step = 100
          }
          "FT8-10m" = {
            name        = "FT8 10m (28.074 MHz)"
            center_freq = 28074000
            samp_rate   = 250000
            start_freq  = 28074000
            start_mod   = "ft8"
            tuning_step = 100
          }
          "WSPR-40m" = {
            name        = "WSPR 40m (7.0386 MHz)"
            center_freq = 7038600
            samp_rate   = 250000
            start_freq  = 7038600
            start_mod   = "wspr"
            tuning_step = 100
          }
          "WSPR-30m" = {
            name        = "WSPR 30m (10.1387 MHz)"
            center_freq = 10138700
            samp_rate   = 250000
            start_freq  = 10138700
            start_mod   = "wspr"
            tuning_step = 100
          }
          "WSPR-20m" = {
            name        = "WSPR 20m (14.0956 MHz)"
            center_freq = 14095600
            samp_rate   = 250000
            start_freq  = 14095600
            start_mod   = "wspr"
            tuning_step = 100
          }
        }
      }
    }
  }

  readsb = {
    renovate = "docker"
    image    = "ghcr.io/sdr-enthusiasts/docker-readsb-protobuf"
    version  = "latest"

    replicas = 0

    latitude  = 42.961356
    longitude = -78.868374

    gain = "autogain"
  }

  rtl_tcp = {
    renovate = "docker"
    image    = "ghcr.io/lizenzfass78851/docker-rtl-tcp"
    version  = "latest"
  }

  tar1090 = {
    renovate = "docker"
    image    = "ghcr.io/sdr-enthusiasts/docker-tar1090"
    version  = "latest"

    subdomain = "adsb"

    beast_host = "readsb.leightha.us"
    uat_host   = "readsb.leightha.us"

    latitude  = 42.961356
    longitude = -78.868374
  }

  trunk_recorder = {
    renovate = "docker"
    image    = "robotastic/trunk-recorder"
    version  = "5.2.1"

    timezone = "UTC"

    source = {
      center = 460500000
      gain   = 39
    }

    systems = [
      {
        short_name = "ecp25"
        type       = "conventionalP25"
        modulation = "fsk4"
        squelch    = -60

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
      }
    ]
  }
}
