inputs = {
  stack = "apps"

  isponsorblocktv = {
    renovate = "docker"
    image    = "dmunozv04/isponsorblocktv"
    version  = "v2.4.0"

    devices = [
      {
        name      = "Apple TV 4K"
        screen_id = "1m9u0bfoh4um94gm2r994bhdt5"
      }
    ]
  }

  smokeping = {
    renovate = "docker"
    image    = "lscr.io/linuxserver/smokeping"
    version  = "2.8.2"

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
