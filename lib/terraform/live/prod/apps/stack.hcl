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
    version  = "17.1.5"

    # ^ hack for renovate to support oci://
    repository = "oci://code.forgejo.org/forgejo-helm"
    chart      = "forgejo"
  }

  ghcr_deploy = {
    renovate = "docker"
    image    = "python"
    version  = "3.14-slim"

    targets = {
      "meshtender/meshtender" = {
        repository = "meshtender/meshtender"
        tag        = "main"

        namespace  = "mesh"
        deployment = "meshtender"
        container  = "meshtender"

        digest_env_var = "MESHTENDER_IMAGE_DIGEST"
      }
    }
  }

  immich = {
    renovate = "docker"
    image    = "ghcr.io/immich-app/immich-charts/immich"
    version  = "0.13.1"

    # ^ hack for renovate to support oci://
    repository = "oci://ghcr.io/immich-app/immich-charts"
    chart      = "immich"

    immich_server = {
      renovate = "docker"
      image    = "ghcr.io/immich-app/immich-server"
      version  = "v3.1.0"
    }
  }

  isponsorblocktv = {
    renovate = "docker"
    image    = "ghcr.io/dmunozv04/isponsorblocktv"
    version  = "v2.11.0"

    auto_play           = false
    minimum_skip_length = 5
  }

  mealie = {
    renovate = "docker"
    image    = "ghcr.io/mealie-recipes/mealie"
    version  = "v3.23.1"
  }

  octoprint = {
    renovate = "docker"
    image    = "docker.io/octoprint/octoprint"
    version  = "1.11.8"
  }

  postgres = {
    renovate   = "helm"
    repository = "https://cloudnative-pg.github.io/charts"
    chart      = "cloudnative-pg"
    version    = "0.29.0"
  }

  reverse_proxy = {
    renovate = "docker"
    image    = "nginx"
    version  = "1.31.4-alpine"

    services = {
      amp = {
        frontend_subdomain = "games"
        backend_host       = "fwd01.leightha.us"
        backend_port       = 8080
        public             = true
      }
      odysseus = {
        frontend_subdomain = "odysseus"
        backend_host       = "fwd01.leightha.us"
        backend_port       = 7000
        public             = false
      }
      sdr = {
        frontend_subdomain = "sdr"
        backend_host       = "192.168.1.245"
        backend_port       = 8073
        public             = true
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

  turnstone = {
    renovate = "docker"
    image    = "ghcr.io/turnstonelabs/turnstone"
    version  = "1.8.1"

    llm_base_url = "http://fwd01.leightha.us:8000/api/v1"
    server_count = 3

    searxng = {
      renovate = "docker"
      image    = "docker.io/searxng/searxng"
      version  = "2026.6.13-a29cda858"
    }
  }

  woodpecker_ci = {
    renovate = "docker"
    image    = "ghcr.io/woodpecker-ci/helm/woodpecker"
    version  = "3.7.1"

    # ^ hack for renovate to support oci://
    repository = "oci://ghcr.io/woodpecker-ci/helm"
    chart      = "woodpecker"
  }
}
