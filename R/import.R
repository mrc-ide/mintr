mintr_db_download <- function(path, quiet = FALSE) {
  version <- mintr_data_version()
  root <- "https://github.com/mrc-ide/mintr/releases/download/data-20230208"
  url <- sprintf("%s/%s.tar", root, version)
  dir.create(path, FALSE, TRUE)
  path_tar <- file.path(path, basename(url))
  if (!file.exists(path_tar)) {
    download_file(url, path_tar, quiet = quiet)
  }
  dest <- file.path(path, version)
  unlink(dest, FALSE, TRUE)
  dir.create(dest, FALSE, TRUE)
  untar(path_tar, exdir = dest)
  unlink(path_tar)
  invisible(dest)
}


mintr_data_version <- function() {
  readLines(mintr_path("version"))
}
