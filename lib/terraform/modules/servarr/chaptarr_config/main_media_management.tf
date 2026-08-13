resource "chaptarr_naming_config" "this" {
  count = local.enabled ? 1 : 0

  rename_books               = true
  replace_illegal_characters = true
  colon_replacement_format   = 4

  author_folder_format = "{Author Name}"
  standard_book_format = "{Book Series}/{Book SeriesPosition:00} - {Book Title} ({Release YearFirst})/{Book Title}{ (PartNumber:smart)}"
}

resource "chaptarr_root_folder" "books" {
  count = local.enabled ? 1 : 0

  name = "Books"
  path = var.books_path

  folder_type = "mixed"

  allow_destroy = false
}
