resource "radarr_naming" "this" {
  count = local.enabled ? 1 : 0

  rename_movies              = true
  replace_illegal_characters = true
  colon_replacement_format   = "delete"

  standard_movie_format = "{Movie Title} ({Release Year}) {Quality Full}"
  movie_folder_format   = "{Movie Title} ({Release Year})"
}
