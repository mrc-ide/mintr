Sys.setenv(PKGAPI_VALIDATE = "true")

mintr_test_db_path <- function() {
  path <- "mint_import_test_db.db"
  if (!file.exists(path)) {
    message("Building test db")
    mintr_test_db_create(path)
  }
  path
}


mintr_test_db <- function() {
  mint_db$new(mintr_test_db_path())
}


mintr_test_db_create <- function(path) {
  options <- mint_baseline_options()
  index <- do.call(expand.grid, c(options, list(stringsAsFactors = FALSE)))
  index$index <- seq_len(nrow(index))

  prevalence <- expand.grid(
    index = index$index,
    month = -12:48,
    netUse = c(0, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1),
    irsUse = c(0, 0.6, 0.7, 0.8, 0.9, 1),
    netType = c("std", "pto"),
    stringsAsFactors = FALSE)
  prevalence$intervention <- mint_intervention(
    prevalence$netUse, prevalence$irsUse, prevalence$netType)
  prevalence$value <- runif(nrow(prevalence))

  mint_db_import(path, index, prevalence)
}
