inputs = {
  stack = "mesh"

  core_scope = {
    renovate = "docker"
    image    = "ghcr.io/kpa-clawbot/corescope"
    version  = "v3.9.2"

    default_region = "BUF"

    regions = {
      "BUF" = "Buffalo"
      "ROC" = "Rochester"
      "YKF" = "Breslau"
      "YLK" = "Barrie"
      "YTR" = "Trenton"
      "YYZ" = "Toronto"
    }

    hash_regions = [
      "#us",
      "#us-ny",
      "#us-ny-buf"
    ]

    map_defaults = {
      center = [43.01, -78.77]
      zoom   = 10
    }

    channel_keys = {
      "Public"      = "8b3387e9c5cdea6ac9e5edbaa115cd72"
      "Meshcore716" = "096a7faa51e9076040a9d4175ec53afc"
    }

    hash_channels = [
      "#bbq",
      "#emergency",
      "#test",
      "#wardriving",
      "#weather",
      "#wny",
      "#xerobot"
    ]

    litestream = {
      renovate = "docker"
      image    = "litestream/litestream"
      version  = "0.5.13"
    }
  }

  mesh_bug = {
    renovate = "docker"
    image    = "ghcr.io/jleight/charts/meshbug"
    version  = "2026.6.1"

    # ^ hack for renovate to support oci://
    repository = "oci://ghcr.io/jleight/charts"
    chart      = "meshbug"
  }

  mqtt = {
    renovate   = "helm"
    repository = "https://vernemq.github.io/docker-vernemq"
    chart      = "vernemq"
    version    = "2.1.2"

    auth = {
      renovate = "docker"
      image    = "python"
      version  = "3.14-slim"
    }
  }

  pymc = {
    renovate = "docker"
    image    = "openhop/openhop-repeater"
    version  = "dev"
    digest   = "sha256:c8781c83c0673b46a7131468e0bb9f3216c7d404cf9cb6333b65f33c7d3446c0"

    subdomain = "pymc"

    serial_port = "/dev/ttyUSB0"
    baud_rate   = 115200

    companions = [
      {
        name = "Xero Base"
      }
    ]

    room_servers = [
      {
        name      = "Leighthaus"
        latitude  = 42.961356
        longitude = -78.868374
      }
    ]

    litestream = {
      renovate = "docker"
      image    = "litestream/litestream"
      version  = "0.5.13"
    }
  }

  meshtender = {
    image  = "git.leightha.us/ci/jleight/meshtender"
    commit = "bf0a907fcc82574f84051ab91f2b9158943c9c00"

    replicas = 2

    hosts = {
      root    = "meshtender.com"
      www     = "www.meshtender.com"
      auth    = "auth.meshtender.com"
      primary = "app.meshtender.com"
    }
  }
}
