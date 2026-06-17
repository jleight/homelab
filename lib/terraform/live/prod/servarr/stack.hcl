inputs = {
  stack = "servarr"

  sabnzbd = {
    renovate = "docker"
    image    = "lscr.io/linuxserver/sabnzbd"
    version  = "5.0.4"

    servers = {
      frugal_main = {
        secret_name = "Frugal Main"
        priority    = 0
        connections = 75
      }
      frugal_alt = {
        secret_name = "Frugal Alt"
        priority    = 1
        connections = 30
      }
      frugal_bonus = {
        secret_name = "Frugal Bonus"
        priority    = 2
        connections = 50
      }
      block_news = {
        secret_name = "Block News"
        priority    = 3
        connections = 50
      }
    }
  }

  qbittorrent = {
    renovate = "docker"
    image    = "lscr.io/linuxserver/qbittorrent"
    version  = "5.2.2-libtorrentv1"

    flood = {
      renovate = "docker"
      image    = "jesec/flood"
      version  = "4.14.2"
    }
  }

  audiobookshelf = {
    renovate = "docker"
    image    = "ghcr.io/advplyr/audiobookshelf"
    version  = "2.35.1"
  }

  radarr = {
    renovate = "docker"
    image    = "lscr.io/linuxserver/radarr"
    version  = "6.2.1"
  }

  sonarr = {
    renovate = "docker"
    image    = "lscr.io/linuxserver/sonarr"
    version  = "4.0.17"
  }

  overseerr = {
    renovate = "docker"
    image    = "ghcr.io/sct/overseerr"
    version  = "1.35.0"
  }

  romm = {
    renovate = "docker"
    image    = "rommapp/romm"
    version  = "4.9.0"

    bridge = {
      renovate = "docker"
      image    = "ghcr.io/jleight/retroarch-romm-bridge"
      version  = "latest"
      digest   = "sha256:80d1d1e2feeb2cb2a042763adeef2fc585b3de8b64cd62b1b12d78108c972339"
    }
  }
}
