resource "sonarr_naming" "this" {
  count = local.enabled ? 1 : 0

  rename_episodes            = true
  replace_illegal_characters = true
  colon_replacement_format   = 4

  standard_episode_format = "{Series Title} - S{season:00}E{episode:00} - {Episode Title} {Quality Full}"
  daily_episode_format    = "{Series Title} - {Air-Date} - {Episode Title} {Quality Full}"
  anime_episode_format    = "{Series Title} - S{season:00}E{episode:00} - {Episode Title} {Quality Full}"
  season_folder_format    = "Season {season:00}"
  multi_episode_style     = 5

  series_folder_format   = "{Series Title}"
  specials_folder_format = "Specials"
}
