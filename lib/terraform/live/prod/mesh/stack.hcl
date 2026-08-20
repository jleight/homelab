inputs = {
  stack = "mesh"

  beacon = {
    beacon_server = {
      renovate = "docker"
      image    = "ghcr.io/meshcore-beacon/beacon-server"
      version  = "1.6.0"
    }

    beacon_web = {
      renovate = "docker"
      image    = "ghcr.io/meshcore-beacon/beacon-web"
      version  = "1.3.0"
    }

    subdomain = "beacon"

    map_center = [43.01, -78.77]
    map_zoom   = 7

    # Effectively "keep everything". Beacon treats 0 as "unset, use the default"
    # rather than "disabled", so there's no way to switch the cleanup task off —
    # a 100-year window puts every cutoff in 1926 and prunes nothing. Growth is
    # roughly 11 MB/day; the db PVC gets resized when it approaches full.
    packet_retention    = "876000h"
    telemetry_retention = "876000h"
    node_delete_after   = "876000h"

    iatas = {
      "BUF" = {
        name = "Buffalo"
        lat  = 42.940498
        lng  = -78.732201
      }
      "ROC" = {
        name = "Rochester"
        lat  = 43.1189
        lng  = -77.672401
      }
      "SYR" = {
        name = "Syracuse"
        lat  = 43.111198
        lng  = -76.106300
      }
      "YKF" = {
        name = "Breslau"
        lat  = 43.4608
        lng  = -80.378601
      }
      "YLK" = {
        name = "Barrie"
        lat  = 44.485056
        lng  = -79.554663
      }
      "YTR" = {
        name = "Trenton"
        lat  = 44.1189
        lng  = -77.528099
      }
      "YYZ" = {
        name = "Toronto"
        lat  = 43.675935
        lng  = -79.629421
      }
    }

    regions = [
      {
        slug          = "western-new-york"
        name          = "Western New York"
        display_order = 1
        center_lat    = 43.01
        center_lng    = -78.77
        zoom_level    = 10
        iatas         = ["BUF", "ROC"]
      },
      {
        slug          = "central-new-york"
        name          = "Central New York"
        display_order = 2
        center_lat    = 43.11
        center_lng    = -76.11
        zoom_level    = 9
        iatas         = ["SYR"]
      },
      {
        slug          = "southern-ontario"
        name          = "Southern Ontario"
        display_order = 3
        center_lat    = 43.9
        center_lng    = -79.4
        zoom_level    = 7
        iatas         = ["YKF", "YLK", "YTR", "YYZ"]
      }
    ]

    # Channel hash (first byte of SHA256 of the key, hex) => key. Beacon can't
    # derive these the way it does hashtag channels, so the hash is explicit.
    channel_keys = {
      "11" = {
        name = "Public"
        key  = "8b3387e9c5cdea6ac9e5edbaa115cd72"
      }
      "4d" = {
        name = "Meshcore716"
        key  = "096a7faa51e9076040a9d4175ec53afc"
      }
    }

    hashtag_channels = [
      "bbq",
      "bot",
      "bots",
      "camping",
      "chat",
      "emergency",
      "games",
      "help",
      "hidden",
      "meshcore",
      "montreal",
      "music",
      "queer",
      "socal",
      "test",
      "toronto",
      "wardriving",
      "weather",
      "wny",
      "xerobot"
    ]

    scopes = [
      "us",
      "us-ny",
      "us-ny-buf",
      "us-ny-cny",
      "us-ny-syr",
      "us-ny-wny"
    ]
  }

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
      version  = "0.5.16"
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
    digest   = "sha256:e44dc4b4d9f8231fa59488fada7524a8fa86b20345e2010e105fb24195fe184f"

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
      version  = "0.5.16"
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
