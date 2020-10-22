#!/usr/bin/env Rscript

## This will likely change as the data that we get from Ellie/Arran
## updates; this script translates the code into a form closer to our
## target, and suitable for use with import.
translate_index <- function(index) {
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

relevel <- function(x, map) {
  i <- match(x, map)
  stopifnot(!any(is.na(i)))
  names(map)[i]
}


rename <- function(x, from, to) {
  i <- match(from, names(x))
  stopifnot(!is.na(i))
  names(x)[i] <- to
  x
}

path_import <- file.path(here::here(), "import")
path_index <- "data_index_tool_data_reshuffle_20201002.rds"
path_value <- "data_values_tool_data_reshuffle_20201002.rds"

index <- translate_index(readRDS(file.path(path_import, path_index)))
value <- readRDS(file.path(path_import, path_value))

prevalence <- value[value$type == "prev" & value$uncertainty == "mean",
                    !(names(value) %in% c("type", "uncertainty"))]
i <- order(prevalence$index)
prevalence <- prevalence[i, ]
rownames(prevalence) <- NULL

tr <- c(netUse = "switch_nets", irsUse = "switch_irs", netType = "NET_TYPE")
prevalence <- rename(prevalence, unname(tr), names(tr))
prevalence$netType <- relevel(prevalence$netType, c(std = 1, pto = 2))

prevalence_config <-
  jsonlite::read_json("inst/json/graph_prevalence_config.json")
prevalence_map <- character()
for (x in prevalence_config$series) {
  if (!is.null(x$id)) {
    prevalence_map[[x$id]] <- x$name
  }
}

prevalence$intervention <- relevel(prevalence$intervention, prevalence_map)

saveRDS(index, file.path(path_import, "index.rds"))
saveRDS(prevalence, file.path(path_import, "prevalence.rds"))

pkgload::load_all()
withr::with_dir(
  path_import,
  mintr:::mint_db_import("mint.db", index, prevalence))
