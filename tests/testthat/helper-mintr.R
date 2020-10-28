Sys.setenv(PKGAPI_VALIDATE = "true")

mintr_test_db <- function() {
  mintr_db_open("data")
}

## Somewhat friendly initialisation script for CI
mintr_test_db_init <- function() {
  if (!file.exists(mintr_db_paths("data")$db)) {
    mintr_db_download("data")
    mintr_db_process("data")
    mintr_db_import("data")
  }
}
