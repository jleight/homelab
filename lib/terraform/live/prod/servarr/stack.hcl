inputs = {
  stack = "servarr"

  sabnzbd = {
    renovate = "docker"
    image    = "lscr.io/linuxserver/sabnzbd"
    version  = "5.1.2"

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
    version  = "5.2.3-libtorrentv1"

    flood = {
      renovate = "docker"
      image    = "jesec/flood"
      version  = "4.16.1"
    }
  }

  audiobookshelf = {
    renovate = "docker"
    image    = "ghcr.io/advplyr/audiobookshelf"
    version  = "2.36.0"
  }

  chaptarr = {
    renovate = "docker"
    image    = "chaptarr/chaptarr"
    version  = "0.9.958"
  }

  radarr = {
    renovate = "docker"
    image    = "lscr.io/linuxserver/radarr"
    version  = "6.3.0"
  }

  romm = {
    renovate = "docker"
    image    = "rommapp/romm"
    version  = "5.2.0"

    bridge = {
      renovate = "docker"
      image    = "ghcr.io/jleight/retroarch-romm-bridge"
      version  = "latest"
      digest   = "sha256:06ffa380dd3653f8ca1059f84ab99b381da6357257ad75e366d5a50006c1a559"
    }
  }

  sonarr = {
    renovate = "docker"
    image    = "lscr.io/linuxserver/sonarr"
    version  = "4.0.19"
  }
}
