Sys.setenv(PKGAPI_VALIDATE = "true")

mintr_test_db <- function() {
  mintr_db_open("data", get_compiled_docs())
}

## Somewhat friendly initialisation script for CI
mintr_test_db_init <- function() {
  path <- file.path("data", mintr_data_version())
  if (!file.exists(mintr_db_paths(path)$index)) {
    mintr_db_download("data")
  }
}
