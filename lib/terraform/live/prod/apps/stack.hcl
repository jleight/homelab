inputs = {
  stack = "apps"

  core_scope = {
    renovate = "docker"
    image    = "ghcr.io/kpa-clawbot/corescope"
    version  = "v3.5.2"

    default_region = "BUF"

    regions = {
      "BUF" = "Buffalo"
    }

    map_defaults = {
      center = [42.88, -78.88]
      zoom = 11
    }

    channel_keys = {
      "Public" = "8b3387e9c5cdea6ac9e5edbaa115cd72"
    }

    hash_channels = [
      "#test",
      "#wardriving",
      "#wny"
    ]

    litestream = {
      renovate = "docker"
      image    = "litestream/litestream"
      version  = "0.5.11"
    }
  }

  dragonflydb = {
    renovate   = "github-tags"
    repository = "dragonflydb/dragonfly-operator"
    version    = "v1.5.0"
    url_format = "https://raw.githubusercontent.com/%s/refs/tags/%s/manifests/dragonfly-operator.yaml"
  }

  forgejo = {
    renovate = "docker"
    image    = "code.forgejo.org/forgejo-helm/forgejo"
    version  = "17.0.1"

    # ^ hack for renovate to support oci://
    repository = "oci://code.forgejo.org/forgejo-helm"
    chart      = "forgejo"
  }

  homebridge = {
    renovate = "docker"
    image    = "ghcr.io/homebridge/homebridge"
    version  = "2025-09-21"
  }

  immich = {
    renovate = "docker"
    image    = "ghcr.io/immich-app/immich-charts/immich"
    version  = "0.11.1"

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
    version  = "v2.7.0"

    auto_play           = false
    minimum_skip_length = 5
  }

  mealie = {
    renovate = "docker"
    image    = "ghcr.io/mealie-recipes/mealie"
    version  = "v3.16.0"
  }

  open_webui = {
    renovate   = "helm"
    repository = "https://helm.openwebui.com"
    chart      = "open-webui"
    version    = "14.2.0"
  }

  plex = {
    renovate = "docker"
    image    = "lscr.io/linuxserver/plex"
    version  = "1.43.1"

    replicas = 0
  }

  postgres = {
    renovate   = "helm"
    repository = "https://cloudnative-pg.github.io/charts"
    chart      = "cloudnative-pg"
    version    = "0.28.0"
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

  reverse_proxy = {
    renovate = "docker"
    image    = "nginx"
    version  = "1.30.0-alpine"

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
    }
  }

  trakr = {
    renovate = "docker"
    image    = "ghcr.io/jleight/trakr"
    version  = "sha-f794e63"
  }
}
