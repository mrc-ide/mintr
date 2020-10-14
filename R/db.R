mint_db <- R6::R6Class(
  "mint_db",
  private = list(
    index = NULL,
    db = NULL,
    baseline = NULL
  ),
  public = list(
    initialize = function(path) {
      private$db <- thor::mdb_env(path, readonly = TRUE, lock = FALSE,
                                  subdir = FALSE)
      private$index <- unserialize(private$db$get("index"))
      private$baseline <- setdiff(names(private$index), "index")
    },

    get_prevalence = function(options) {
      assert_setequal(names(options), private$baseline)
      valid <- rep(TRUE, nrow(private$index))
      for (i in names(options)) {
        valid <- valid & options[[i]] == private$index[[i]]
        if (!any(valid)) {
          stop(sprintf("No matching value '%s' for option '%s'",
                       options[[i]], i))
        }
      }
      stopifnot(sum(valid) == 1L) # this will always be true
      key <- private$index$index[valid]
      unserialize(private$db$get(sprintf("prevalence:%s", key)))
    }
  ))


## We should do this both on writing to the db and on reading to it?
mint_baseline_options <- function() {
  path <- mintr_path("json/baseline_options.json")
  baseline <- jsonlite::fromJSON(path, FALSE)
  index <- list()
  for (section in baseline$controlSections) {
    for (group in section$controlGroups) {
      for (control in group$controls) {
        if (control$type == "select" && control$name != "metabolic") {
          index[[control$name]] <- vcapply(control$options, "[[", "id")
        }
      }
    }
  }
  index
}


mint_db_import <- function(path, index, prevalence) {
  mint_db_check_index(index)
  mint_db_check_prevalence(index, prevalence)

  unlink(path, recursive = TRUE)
  db <- thor::mdb_env(path, mapsize = 4e9, subdir = FALSE)
  db$put("index", object_to_bin(index))

  ## Prevalence:
  idx <- split(seq_len(nrow(prevalence)), prevalence$index)
  for (i in index$index) {
    d <- prevalence[idx[[i]], names(prevalence) != "index"]
    rownames(d) <- NULL
    db$put(sprintf("prevalence:%s", i), object_to_bin(d))
  }
}


mint_db_check_index <- function(index) {
  baseline <- mint_baseline_options()
  assert_setequal(names(index), c(names(baseline), "index"))
  for (i in names(baseline)) {
    assert_setequal(index[[i]], baseline[[i]], sprintf("index$%s", i))
  }
}


mint_db_check_prevalence <- function(index, prevalence) {
  cols <- c("month", "value", "netUse", "irsUse", "netType", "intervention",
            "index")
  assert_setequal(names(prevalence), cols)
  assert_setequal(prevalence$index, index$index)
}


mint_intervention <- function(net_use, irs_use, net_type) {
  intervention <- c(                # net_use  irs_use  net_type
    "No intervention",              # == 0     == 0     == std
    "Pyrethroid LLIN only",         #  > 0     == 0     == std
    "IRS only",                     # == 0      > 0     == std
    "Pyrethroid LLIN with IRS",     #  > 0      > 0     == std
    "No intervention",              # == 0     == 0     == pto
    "Pyrethroid-PBO LLIN only",     #  > 0     == 0     == pto
    "IRS only",                     # == 0      > 0     == pto
    "Pyrethroid-PBO LLIN with IRS") #  > 0      > 0     == pto

  ## Use bit packing to get the above relationship:
  i <- (net_use > 0) + (irs_use > 0) * 2 + (net_type == "pto") * 4 + 1
  intervention[i]
}


## Organise collecing the real data for use within the app. See the
## notes in import/README.md for shipping the files out to the server
## where they can be found.
mintr_open_db <- function(path) {
  dest <- file.path(path, "mintr.db")
  if (!file.exists(path)) {
    message("Downloading the data")
    download_mintr_data(path)
    message("Importing the data into the db")
    mint_db_import(dest,
                   readRDS(file.path(path, "index.rds")),
                   readRDS(file.path(path, "prevalence.rds")))
    message("Database ready")
  }
  mint_db$new(dest)
}


download_mintr_data <- function(dest, overwrite = FALSE) {
  dir.create(dest, FALSE, TRUE)
  files <- c("index.rds", "prevalence.rds")
  base <- "https://mrcdata.dide.ic.ac.uk/mint/"
  for (f in files) {
    if (overwrite || !file.exists(file.path(dest, f))) {
      download_file(paste0(base, f), file.path(dest, f))
    }
  }
  dest
}
