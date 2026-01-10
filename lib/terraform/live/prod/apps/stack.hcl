inputs = {
  stack = "apps"

  dragonflydb = {
    renovate   = "github-tags"
    repository = "dragonflydb/dragonfly-operator"
    version    = "v1.3.1"
    url_format = "https://raw.githubusercontent.com/%s/refs/tags/%s/manifests/dragonfly-operator.yaml"
  }

  forgejo = {
    renovate = "docker"
    image    = "code.forgejo.org/forgejo-helm/forgejo"
    version  = "15.0.3"

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
    version  = "0.10.3"

    # ^ hack for renovate to support oci://
    repository = "oci://ghcr.io/immich-app/immich-charts"
    chart      = "immich"

    immich_server = {
      renovate = "docker"
      image    = "ghcr.io/immich-app/immich-server"
      version  = "v2.4.1"
    }
  }

  isponsorblocktv = {
    renovate = "docker"
    image    = "dmunozv04/isponsorblocktv"
    version  = "v2.6.1"

    devices = [
      {
        name      = "Apple TV 4K"
        screen_id = "1m9u0bfoh4um94gm2r994bhdt5"
      }
    ]
  }

  mealie = {
    renovate = "docker"
    image    = "ghcr.io/mealie-recipes/mealie"
    version  = "v3.9.2"
  }

  open_webui = {
    renovate   = "helm"
    repository = "https://helm.openwebui.com"
    chart      = "open-webui"
    version    = "10.1.0"
  }

  plex = {
    renovate = "docker"
    image    = "lscr.io/linuxserver/plex"
    version  = "1.42.2"
  }

  postgres = {
    renovate   = "helm"
    repository = "https://cloudnative-pg.github.io/charts"
    chart      = "cloudnative-pg"
    version    = "0.27.0"
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
}
