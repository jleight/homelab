inputs = {
  stack = "mesh"

  core_scope = {
    renovate = "docker"
    image    = "ghcr.io/kpa-clawbot/corescope"
    version  = "v3.7.2"

    default_region = "BUF"

    regions = {
      "BUF" = "Buffalo"
      "ROC" = "Rochester"
      "YKF" = "Breslau"
      "YLK" = "Barrie"
      "YTR" = "Trenton"
      "YYZ" = "Toronto"
    }

    map_defaults = {
      center = [42.88, -78.88]
      zoom   = 11
    }

    channel_keys = {
      "Public" = "8b3387e9c5cdea6ac9e5edbaa115cd72"
    }

    hash_channels = [
      "#test",
      "#wardriving",
      "#wny",
      "#xerobot"
    ]

    litestream = {
      renovate = "docker"
      image    = "litestream/litestream"
      version  = "0.5.11"
    }
  }

  mesh_bug = {
    renovate = "docker"
    image    = "ghcr.io/jleight/charts/meshbug"
    version  = "2026.5.2"

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
}
