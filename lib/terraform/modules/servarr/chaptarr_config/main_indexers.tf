resource "chaptarr_indexer" "nzbfinder" {
  count = local.enabled ? 1 : 0

  name     = "NZB Finder"
  enable   = true
  priority = 25

  implementation  = "Newznab"
  config_contract = "NewznabSettings"

  enable_rss                = true
  enable_automatic_search   = true
  enable_interactive_search = true

  field_values_json = jsonencode({
    baseUrl = "https://nzbfinder.ws"
    apiPath = "/api"

    categories = [3030, 7020, 7030, 7999]

    earlyReleaseLimit    = null
    additionalParameters = null

    enableNarratorMetadata  = false
    narratorMetadataBaseUrl = null
  })

  secret_fields = {
    apiKey = local.enabled ? data.onepassword_item.nzbfinder[0].credential : ""
  }

  test_on_apply = false
}
