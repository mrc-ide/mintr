`%||%` <- function(a, b) { # nolint
  if (is.null(a)) b else a
}


mintr_path <- function(path) {
  system.file(path, package = "mintr", mustWork = TRUE)
}


## TODO: This will be removed once RESIDE-121 is fixed
schema_root <- function() {
  mintr_path("schema")
}


read_json <- function(path) {
  str <- paste(readLines(path), collapse = "\n")
  class(str) <- "json"
  str
}
