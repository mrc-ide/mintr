## See notes in import/README.md for how the files that this import
## should be setup.
mintr_db_open <- function(path, overwrite = FALSE) {
  mintr_db_init("mintr.db", path, overwrite)
}


mintr_db_init <- function(name, path, overwrite = FALSE) {
  path_db <- file.path(path, name)

  data <- mintr_db_process(path, overwrite)
  if (overwrite) {
    unlink(path_db)
    unlink(paste0(path_db, "-lock"))
  }
  if (!file.exists(path_db)) {
    message("Building database")
    mintr_db_import(path_db, readRDS(data$index), readRDS(data$prevalence))
  }

  mintr_db$new(path_db)
}


mintr_db_process <- function(path, overwrite = FALSE) {
  files <- list(index = file.path(path, "index.rds"),
                prevalence = file.path(path, "prevalence.rds"))

  if (overwrite || !file.exists(files$index)) {
    raw <- mintr_db_download(path)
    message("Processing index")
    index <- import_translate_index(readRDS(raw$index))
    saveRDS(index, files$index)
  }

  if (overwrite || !file.exists(files$prevalence)) {
    raw <- mintr_db_download(path)
    message("Processing prevalence")
    prevalence <- readRDS(raw$prevalence)
    ## The incoming raw data has *way* too much stuff in it; I've
    ## asked Arran to remove it so that we get a lighter download.
    prevalence <- prevalence[
      prevalence$type == "prev" & prevalence$uncertainty == "mean",
      !(names(prevalence) %in% c("type", "uncertainty"))]
    i <- order(prevalence$index)
    prevalence <- prevalence[i, ]
    rownames(prevalence) <- NULL

    tr <- c(netUse = "switch_nets",
            irsUse = "switch_irs",
            netType = "NET_TYPE")
    prevalence <- rename(prevalence, unname(tr), names(tr))
    prevalence$netType <- relevel(prevalence$netType, c(std = 1, pto = 2))
    prevalence$intervention <- relevel(prevalence$intervention,
                                       import_intervention_map())

    saveRDS(prevalence, files$prevalence)
  }

  files
}


mintr_db_download <- function(path, overwrite = FALSE) {
  info <- jsonlite::read_json(mintr_path("data.json"))

  dest <- file.path(path, info$directory)
  dir.create(dest, FALSE, TRUE)
  for (f in info$files) {
    if (overwrite || !file.exists(file.path(dest, f))) {
      message(sprintf("Downloading '%s'", f))
      download_file(file.path(info$root, info$directory, f),
                    file.path(dest, f))
    }
  }
  lapply(info$files, function(f) file.path(path, info$directory, f))
}


## Worked out with Arran by looking at their data
import_translate_index <- function(index) {
  remap <- list(
    list(
      from = "res1",
      to = "levelOfResistance",
      map = c("0%" = 0, "20%" = 20, "40%" = 40,
              "60%" = 60, "80%" = 80, "100%" = 100)),
    list(
      from = "season",
      to = "seasonalityOfTransmission",
      map = c(seasonal = 1, perennial = 2)),
    list(
      from = "endem",
      to = "currentPrevalence",
      map = c(low = 0.05, med = 0.3, high = 0.6)),
    list(
      from = "phi",
      to = "bitingIndoors",
      map = c(high = 0.97, low = 0.78)),
    list(
      from = "Q0",
      to = "bitingPeople",
      map = c(high = 0.92, low = 0.74)),
    list(
      from = "nets",
      to = "itnUsage",
      map = c("0%" = 0.0, "20%" = 0.2, "40%" = 0.4,
              "60%" = 0.6, "80%" = 0.8)),
    list(
      from = "sprays",
      to = "sprayInput",
      map = c("0%" = 0.0, "80%" = 0.8)))

  for (x in remap) {
    index <- rename(index, x$from, x$to)
    index[[x$to]] <- relevel(index[[x$to]], x$map)
  }

  index
}


## Intervention mappings come from our metadata
import_intervention_map <- function() {
  config <- jsonlite::read_json(mintr_path("json/graph_prevalence_config.json"))
  map <- character()
  for (x in config$series) {
    if (!is.null(x$id)) {
      map[[x$id]] <- x$name
    }
  }
  map
}


mintr_db_docker <- function(path) {
  raw <- jsonlite::read_json(mintr_path("data.json"))$directory
  mintr_db_open(path)
  ## Remove intermediate and derived files so that we get something
  ## nice and small to keep in the docker image:
  unlink(file.path(path, "mintr.db"))
  unlink(file.path(path, "mintr.db-lock"))
  unlink(file.path(path, raw), recursive = TRUE)
}
