inputs = {
  stack = "apps"

  dragonflydb = {
    renovate   = "github-tags"
    repository = "dragonflydb/dragonfly-operator"
    version    = "v1.6.1"
    url_format = "https://raw.githubusercontent.com/%s/refs/tags/%s/manifests/dragonfly-operator.yaml"
  }

  forgejo = {
    renovate = "docker"
    image    = "code.forgejo.org/forgejo-helm/forgejo"
    version  = "17.1.1"

    # ^ hack for renovate to support oci://
    repository = "oci://code.forgejo.org/forgejo-helm"
    chart      = "forgejo"
  }

  immich = {
    renovate = "docker"
    image    = "ghcr.io/immich-app/immich-charts/immich"
    version  = "0.12.0"

    # ^ hack for renovate to support oci://
    repository = "oci://ghcr.io/immich-app/immich-charts"
    chart      = "immich"

    immich_server = {
      renovate = "docker"
      image    = "ghcr.io/immich-app/immich-server"
      version  = "v2.7.5"
    }
  }

  isponsorblocktv = {
    renovate = "docker"
    image    = "ghcr.io/dmunozv04/isponsorblocktv"
    version  = "v2.9.0"

    auto_play           = false
    minimum_skip_length = 5
  }

  mealie = {
    renovate = "docker"
    image    = "ghcr.io/mealie-recipes/mealie"
    version  = "v3.19.2"
  }

  octoprint = {
    renovate = "docker"
    image    = "docker.io/octoprint/octoprint"
    version  = "1.11.7"
  }

  open_webui = {
    renovate   = "helm"
    repository = "https://helm.openwebui.com"
    chart      = "open-webui"
    version    = "14.8.0"
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
        name            = "RTL-SDR"
        type            = "rtl_sdr"
        direct_sampling = 0

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

  plex = {
    renovate = "docker"
    image    = "lscr.io/linuxserver/plex"
    version  = "1.43.2"

    replicas = 0
  }

  postgres = {
    renovate   = "helm"
    repository = "https://cloudnative-pg.github.io/charts"
    chart      = "cloudnative-pg"
    version    = "0.28.3"
  }

  reverse_proxy = {
    renovate = "docker"
    image    = "nginx"
    version  = "1.31.1-alpine"

    services = {
      amp = {
        frontend_subdomain = "games"
        backend_host       = "fwd01.leightha.us"
        backend_port       = 8080
        public             = true
      }
      lemonade = {
        frontend_subdomain = "lemonade"
        backend_host       = "fwd01.leightha.us"
        backend_port       = 8000
        public             = false
      }
      odysseus = {
        frontend_subdomain = "odysseus"
        backend_host       = "fwd01.leightha.us"
        backend_port       = 7000
        public             = false
      }
    }
  }

  smokeping = {
    renovate = "docker"
    image    = "lscr.io/linuxserver/smokeping"
    version  = "2.9.0"

    subdomain     = "ping"
    owner         = "Jonathon Leight"
    contact_email = "smokeping@jleight.com"
    time_zone     = "America/New_York"

    targets_dns = {
      cloudflare = {
        name  = "Cloudflare"
        hosts = ["1.1.1.1"]
      }
      google = {
        name  = "Google"
        hosts = ["8.8.8.8", "8.8.4.4"]
      }
      nextdns = {
        name  = "NextDNS"
        hosts = ["45.90.28.53", "45.90.30.53"]
      }
    }

    targets_external = {
      cloudflare = {
        name = "Cloudflare"
        host = "cloudflare.com"
      }
      google = {
        name = "Google"
        host = "google.com"
      }
      kagi = {
        name = "Kagi"
        host = "kagi.com"
      }
      rit = {
        name = "RIT"
        host = "csh.rit.edu"
      }
      youtube = {
        name = "YouTube"
        host = "youtube.com"
      }
    }

    targets_internal = {
      router = {
        name = "gwudmpro01"
        host = "192.168.1.1"
      }
      nas02 = {
        name = "nas02"
        host = "192.168.1.251"
      }
      ha01 = {
        name = "ha01"
        host = "192.168.1.252"
      }
      srv01 = {
        name = "srv01"
        host = "192.168.1.253"
      }
      nas01 = {
        name = "nas01"
        host = "192.168.1.254"
      }
    }
  }

  trakr = {
    renovate = "docker"
    image    = "ghcr.io/jleight/trakr"
    version  = "sha-f794e63"
  }

  turnstone = {
    renovate = "docker"
    image    = "ghcr.io/turnstonelabs/turnstone"
    version  = "1.6.4"

    llm_base_url = "https://lemonade.leightha.us/api/v1"
    server_count = 3

    searxng = {
      renovate = "docker"
      image    = "docker.io/searxng/searxng"
      version  = "2026.6.13-a29cda858"
    }
  }
}
