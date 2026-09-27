inputs = {
  stack = "mesh"

  core_scope = {
    renovate = "docker"
    image    = "ghcr.io/kpa-clawbot/corescope"
    version  = "v3.12.0"

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
      version  = "0.5.17"
    }
  }

  mqtt = {
    renovate   = "helm"
    repository = "https://vernemq.github.io/docker-vernemq"
    chart      = "vernemq"
    version    = "2.2.0"

    auth = {
      renovate = "docker"
      image    = "python"
      version  = "3.14-slim"
    }
  }

  meshtender = {
    image = "ghcr.io/meshtender/meshtender"
    tag   = "main"

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
