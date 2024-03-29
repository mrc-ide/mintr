`%||%` <- function(a, b) { # nolint
  if (is.null(a)) b else a
}


mintr_path <- function(path) {
  system.file(path, package = "mintr", mustWork = TRUE)
}


read_json <- function(path) {
  str <- paste(readLines(path), collapse = "\n")
  class(str) <- "json"
  str
}


html_string_as_json <- function(str) {
  str <- gsub('\n', ' ', str)
  str <- paste0("\"", str, "\"")
  class(str) <- "json"
  str
}


vcapply <- function(x, fun, ...) {
  vapply(x, fun, character(1), ...)
}


assert_setequal <- function(values, expected,
                            name = deparse(substitute(values))) {
  given <- unique(values)
  if (!setequal(given, expected)) {
    unexpected <- setdiff(given, expected)
    missing <- setdiff(expected, given)

    msg <- sprintf("Invalid value for '%s':", name)
    if (length(unexpected) > 0) {
      msg <- c(msg,
               paste("  - Unexpected:", paste(unexpected, collapse = ", ")))
    }
    if (length(missing) > 0) {
      msg <- c(msg,
               paste("  - Missing:", paste(missing, collapse = ", ")))
    }
    stop(paste(msg, collapse = "\n"), call. = FALSE)
  }
}


download_file <- function(url, dest, ...) {
  oo <- options(timeout = 1800) # 30 mins
  on.exit(options(oo))
  withCallingHandlers(
    utils::download.file(url, dest, mode = "wb", ...),
    error = function(e) unlink(dest))
}
