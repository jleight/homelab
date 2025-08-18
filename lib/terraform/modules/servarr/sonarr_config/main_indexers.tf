resource "sonarr_indexer_newznab" "nzbfinder" {
  count = local.enabled ? 1 : 0

  name     = "NZB Finder"
  priority = 1

  base_url   = "https://nzbfinder.ws"
  api_key    = local.enabled ? data.onepassword_item.nzbfinder[0].credential : ""
  categories = [5040, 5045, 5070]

  enable_rss                = true
  enable_automatic_search   = true
  enable_interactive_search = true
}
