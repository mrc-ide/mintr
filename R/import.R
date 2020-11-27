## Convert our processed data (index.rds and prevelance.rds) into a
## mintr database; this will be called in the docker image on startup
mintr_db_import <- function(path) {
  message("Building database")
  paths <- mintr_db_paths(path)

  index <- readRDS(paths$index)
  prevalence <- readRDS(paths$prevalence)
  table <- readRDS(paths$table)

  ignore <- mintr_db_check_index(index)
  #mintr_db_check_prevalence(index, prevalence)

  unlink(paths$db, recursive = TRUE)
  unlink(paths$db_lock, recursive = TRUE)
  db <- thor::mdb_env(paths$db, mapsize = 4e9, subdir = FALSE)
  db$put("index", object_to_bin(index))
  db$put("ignore", object_to_bin(ignore))

  ## Table:
  idx <- split(seq_len(nrow(table)), table$index)
  for (i in index$index) {
    d <- table[idx[[i]], !(names(table) %in% c("index", "netType"))]
    rownames(d) <- NULL
    db$put(sprintf("table:%s", i), object_to_bin(d))
  }

  ## Prevalence:
  idx <- split(seq_len(nrow(prevalence)), prevalence$index)
  for (i in index$index) {
    d <- prevalence[idx[[i]], !(names(prevalence) %in% c("index", "netType"))]
    rownames(d) <- NULL
    db$put(sprintf("prevalence:%s", i), object_to_bin(d))
  }
}


## Process raw data; this will be called during the docker image build
mintr_db_process <- function(path) {
  raw <- jsonlite::read_json(mintr_path("data.json"))
  paths <- mintr_db_paths(path)

  message("Processing index")
  path_index_raw <- file.path(path, raw$directory, raw$files$index)
  index <- import_translate_index(readRDS(path_index_raw))
  saveRDS(index, paths$index)

  message("Processing prevalence")
  path_prevalence_raw <- file.path(path, raw$directory, raw$files$prevalence)
  prevalence <- readRDS(path_prevalence_raw)
  ### The incoming raw data has *way* too much stuff in it; I've
  ### asked Arran to remove it so that we get a lighter download.
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
  prevalence$year <- NULL
  prevalence <- add_zero_series(prevalence)

  saveRDS(prevalence, paths$prevalence)

  message("Processing table")
  path_table_raw <- file.path(path, raw$directory, raw$files$table)
  table <- readRDS(path_table_raw)

  tr <- c(netUse = "switch_nets",
          irsUse = "switch_irs",
          netType = "NET_type",
          casesAverted = "cases_averted",
          prevYear1 = "prev_1_yr_post",
          prevYear2 = "prev_2_yr_post",
          prevYear3 = "prev_3_yr_post",
          reductionInPrevalence = "relative_reduction_in_prevalence",
          reductionInCases = "relative_reduction_in_cases",
          meanCases = "cases_per_person_3_years")
  table <- rename(table, unname(tr), names(tr))
  table$intervention <- relevel(table$intervention,
                                import_intervention_map())

  table <- add_zero_series(table)

  ## At this point casesAverted is really over 3 years and is cases
  ## averted per person. This number can be greater than one as a
  ## person can have more than one case per year. We remove the year
  ## effect first:
  table$casesAverted <- table$casesAverted / 3

  ## Then compute the "per 1000" case before the uncertainty calculation:
  table$casesAvertedPer1000 <- round(table$casesAverted * 1000)

  ## Convert these into as percentages, rounded to the nearest d.p.
  table$reductionInCases <- round(table$reductionInCases * 100, 1)
  table$reductionInPrevalence <- round(table$reductionInPrevalence * 100, 1)

  t_low <- table[table$uncertainty == "low", ]
  t_high <- table[table$uncertainty == "high", ]
  table <- table[table$uncertainty == "mean", ]
  ## Check that our tables align so that the uncertainty calculations
  ## can be added:
  rownames(table) <- rownames(t_low) <- rownames(t_high) <- NULL
  v_index <- c("index", "netUse", "irsUse", "netType", "intervention")
  stopifnot(identical(table[v_index], t_low[v_index]),
            identical(table[v_index], t_high[v_index]))

  v_uncertainty <- c("casesAvertedPer1000", "reductionInCases")
  for (v in v_uncertainty) {
    table[[paste0(v, "ErrorMinus")]] <- t_low[[v]]
    table[[paste0(v, "ErrorPlus")]] <- t_high[[v]]
  }

  table$netType <- relevel(table$netType, c(std = 1, pto = 2))

  drop <- c("uncertainty", grep("_", names(table), value = TRUE))
  table <- table[setdiff(names(table), drop)]

  saveRDS(table, paths$table)
}


add_zero_series <- function(data) {
  cols <- setdiff(names(data), "intervention")

  intervention <- "irs"
  # add values for irsUse = 0
  # irs = none in this case
  i_src <- data$intervention == "none"
  d <- data[i_src & data$irsUse == 0, cols]
  d$intervention <- intervention
  data <- rbind(data, d)

  for (intervention in c("irs-llin", "irs-llin-pbo")) {
    # add values for irsUse = 0
    # irs-llin = llin, irs-llin-pbo = llin-pbo in this case
    src <- sub("irs-", "", intervention)
    i_src <- data$intervention == src
    d <- data[i_src & data$irsUse == 0, cols]
    d$intervention <- intervention
    data <- rbind(data, d)

    # add values for netUse = 0
    # irs-llin = irs-llin-pbo = pbo in this case
    i_src <- data$intervention == "irs"
    d <- data[i_src & data$netUse == 0, cols]
    d$intervention <- intervention
    data <- rbind(data, d)
  }

  for (intervention in c("llin", "llin-pbo")) {
    # add values for netUse = 0
    # llin = llin-pbo = none in this case
    i_src <- data$intervention == "none"
    d <- data[i_src & data$netUse == 0, cols]
    d$intervention <- intervention
    data <- rbind(data, d)
  }

  data[data$intervention %in% c("llin", "llin-pbo"), ]$irsUse <- "n/a"
  data[data$intervention =="irs", ]$netUse <- "n/a"
  data[data$intervention =="none", ]$netUse <- "n/a"
  data[data$intervention =="none", ]$irsUse <- "n/a"
  data
}


## Download raw data; will be called in the docker image build
mintr_db_download <- function(path) {
  info <- jsonlite::read_json(mintr_path("data.json"))

  dest <- file.path(path, info$directory)
  dir.create(dest, FALSE, TRUE)
  for (f in info$files) {
    if (!file.exists(file.path(dest, f))) {
      message(sprintf("Downloading '%s'", f))
      download_file(file.path(info$root, info$directory, f),
                    file.path(dest, f))
    }
  }
  lapply(info$files, function(f) file.path(path, info$directory, f))
  invisible(file.path(path, info$directory))
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
  path_downloads <- mintr_db_download(path)
  mintr_db_process(path)

  ## Remove intermediate and derived files so that we get something
  ## nice and small to keep in the docker image:
  unlink(path_downloads, recursive = TRUE)
}
