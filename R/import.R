## Process raw data; this will be called during the docker image build
mintr_db_process <- function(path) {
  raw <- jsonlite::read_json(mintr_path("data.json"))
  paths <- mintr_db_paths(path)
  interventions <- raw$interventions
  net_types <- c(std = 1, pto = 2, ig2 = 3)

  unlink(paths$index)
  unlink(paths$ignore)
  unlink(dirname(paths$prevalence), recursive = TRUE)
  unlink(dirname(paths$table), recursive = TRUE)

  message("Processing index")
  path_index_raw <- file.path(path, raw$directory, raw$files$index)
  index <- import_translate_index(readRDS(path_index_raw))
  ignore <- mintr_db_check_index(index)

  message("Processing prevalence")
  path_prevalence_raw <- file.path(path, raw$directory, raw$files$prevalence)
  prevalence <- mintr_db_process_prevalence(readRDS(path_prevalence_raw),
                                            interventions, net_types)
  gc() # running low on RAM on workers, make sure we don't keep another copy

  mintr_db_check_prevalence(index, prevalence)

  message("Writing prevalence")
  dir.create(dirname(paths$prevalence), FALSE, TRUE)
  idx <- split(seq_len(nrow(prevalence)), prevalence$index)
  stopifnot(setequal(index$index, names(idx)))

  for (i in index$index) {
    d <- prevalence[idx[[i]], !(names(prevalence) %in% c("index", "netType"))]
    rownames(d) <- NULL
    saveRDS(d, sprintf(paths$prevalence, i))
  }

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

  as_numeric <- c("casesAverted", "reductionInPrevalence", "reductionInCases",
                  "meanCases")
  table[as_numeric] <- lapply(table[as_numeric], as.numeric)

  ## Check that all cases_averted values are non-negative (see mrc-2206)
  stopifnot(table$casesAverted >= 0)

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
  table <- table[table$uncertainty == "median", ]
  ## Check that our tables align so that the uncertainty calculations
  ## can be added:
  rownames(table) <- rownames(t_low) <- rownames(t_high) <- NULL
  v_index <- c("index", "netUse", "irsUse", "netType", "intervention")

  ## In the 20220707 data set and later, the table 't_low' is not
  ## aligned with the base data, fix that here as we assume it below.
  t_low <- sort_table(t_low, table)
  t_high <- sort_table(t_high, table)

  v_uncertainty <- c("casesAverted",
                     "casesAvertedPer1000",
                     "prevYear1",
                     "prevYear2",
                     "prevYear3",
                     "reductionInPrevalence",
                     "reductionInCases",
                     "meanCases")
  for (v in v_uncertainty) {
    ## Re-order confidence values and extend bounds to include mean if necessary (mrc-2193)
    low_high_mean <- cbind(t_low[[v]], t_high[[v]], table[[v]])
    table[[paste0(v, "ErrorMinus")]] <- apply(low_high_mean, 1, min)
    table[[paste0(v, "ErrorPlus")]]  <- apply(low_high_mean, 1, max)
  }

  table$netType <- relevel(table$netType, net_types)
  table$intervention <- relevel(table$intervention, interventions)

  drop <- c("uncertainty", grep("_", names(table), value = TRUE))
  table <- table[setdiff(names(table), drop)]

  message("Writing table")
  dir.create(dirname(paths$table), FALSE, TRUE)
  idx <- split(seq_len(nrow(table)), table$index)
  stopifnot(setequal(index$index, names(idx)))
  for (i in index$index) {
    d <- table[idx[[i]], !(names(table) %in% c("index", "netType"))]
    rownames(d) <- NULL
    dest <- sprintf(paths$table, i)
    saveRDS(d, dest)
  }

  ## Save the index last; that's the file we'll use to detect if
  ## things need rebuilding
  saveRDS(ignore, paths$ignore)
  saveRDS(index, paths$index)
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
      from = "resistance",
      to = "levelOfResistance",
      map = c("0%" = 0, "20%" = 20, "40%" = 40,
              "60%" = 60, "80%" = 80, "100%" = 100)),
    list(
      from = "seasonal",
      to = "seasonalityOfTransmission",
      map = c(seasonal = 1, perennial = 2)),
    list(
      from = "prevalence",
      to = "currentPrevalence",
      map = c("5%" = 0.05, "10%" = 0.1, "20%" = 0.2, "30%" = 0.3, "40%" = 0.4,
              "50%" = 0.5, "60%" = 0.6)),
    list(
      from = "biting_inbed_indoors",
      to = "bitingIndoors",
      map = c(high = "high", low = "low")),
    list(
      from = "anthropophagy",
      to = "bitingPeople",
      map = c(high = "high", low = "low")),
    list(
      from = "itn_use",
      to = "itnUsage",
      map = c("0%" = 0.0, "20%" = 0.2, "40%" = 0.4,
              "60%" = 0.6, "80%" = 0.8)),
    list(
      from = "irs_use",
      to = "sprayInput",
      map = c("0%" = 0.0, "60%" = 0.6, "80%" = 0.8)))

  for (x in remap) {
    index <- rename(index, x$from, x$to)
    index[[x$to]] <- relevel(index[[x$to]], x$map)
  }

  index$net_type_use <- NULL
  index$uncertainty_draw <- NULL

  ## Avoids relying on the index being complete, which is no longer
  ## the case (since the 20221017 dataset)
  index$index <- as.character(index$index)

  index
}

mintr_db_docker <- function(path) {
  path_downloads <- mintr_db_download(path)
  mintr_db_process(path)

  ## Remove intermediate and derived files so that we get something
  ## nice and small to keep in the docker image:
  unlink(path_downloads, recursive = TRUE)
}



sort_table <- function(t, ref) {
  v_index <- c("index", "netUse", "irsUse", "netType", "intervention")
  if (identical(t[v_index], ref[v_index])) {
    return(t)
  }
  message(sprintf("...resorting table %s", deparse(substitute(t))))
  key_t <- paste(t$index, t$netUse, t$irsUse, t$netType, t$intervention)
  key_ref <- paste(ref$index, ref$netUse, ref$irsUse, ref$netType,
                   ref$intervention)
  i <- match(key_ref, key_t)
  stopifnot(!anyNA(i))
  t <- t[i, ]
  rownames(t) <- NULL
  t
}

mintr_db_process_prevalence <- function(prevalence, interventions, net_types) {
  prevalence <- prevalence[prevalence$uncertainty == "median", ]
  i <- order(prevalence$index)
  prevalence <- prevalence[i, ]
  rownames(prevalence) <- NULL

  tr <- c(netUse = "switch_nets",
          irsUse = "switch_irs",
          netType = "NET_type")
  prevalence <- rename(prevalence, unname(tr), names(tr))
  prevalence$netType <- relevel(prevalence$netType, net_types)
  prevalence$intervention <- relevel(prevalence$intervention, interventions)
  prevalence <- prevalence[prevalence$type == "prev", ]
  prevalence$year <- NULL
  prevalence$type <- NULL
  prevalence$uncertainty <- NULL
  row.names(prevalence) <- NULL
  prevalence
}
