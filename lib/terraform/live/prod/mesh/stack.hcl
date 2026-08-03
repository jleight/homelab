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
      version  = "0.5.15"
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
    digest   = "sha256:14e4ab29acea8006146487a4e2d437e13c699a91712d5b26c3282ba0e5b6810c"

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
      version  = "0.5.15"
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

    mail = {
      from     = "MeshTender <support@mail.meshtender.com>"
      reply_to = "MeshTender Support <support@meshtender.com>"
    }
  }

  pgtt = {
    image  = "git.leightha.us/ci/jleight/pgtt"
    commit = "ad4d4a2ddd6de71fc09defe163694e92052f6284"

    replicas = 2
  }
}
