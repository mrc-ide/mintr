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


vcapply <- function(x, fun, ...) {
  vapply(x, fun, character(1), ...)
}


object_to_bin <- function(x) {
  serialize(x, NULL, xdr = FALSE)
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
