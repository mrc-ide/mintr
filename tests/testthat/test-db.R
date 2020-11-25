context("db")

test_that("Can create db", {
  db <- mintr_test_db()
  expect_error(db$get_prevalence(list()),
               "Invalid value for 'names(options)'", fixed = TRUE)
  options <- list(seasonalityOfTransmission = "seasonal",
                  currentPrevalence = "med",
                  bitingIndoors = "high",
                  bitingPeople = "low",
                  levelOfResistance = "80%",
                  itnUsage = "20%",
                  sprayInput = "0%")
  d <- db$get_prevalence(options)
  expect_s3_class(d, "data.frame")
  expect_equal(nrow(d), 120 * 61)
  expect_setequal(
    names(d),
    c("month", "netUse", "irsUse", "netType", "intervention", "value"))

  impact <- db$get_impact_docs()
  cost <- db$get_cost_docs()
  expect_is(impact, "json")
  expect_is(cost, "json")

  expect_true(grepl("<strong>Impact</strong>", impact))
  expect_true(grepl("<strong>Cost Effectiveness</strong>", cost))
})


test_that("error if db not present", {
  expect_error(
    mintr_db_open(tempfile()),
    "mintr database does not exist at '.+mintr.db'")
})


test_that("can ignore some keys", {
  options <- list(seasonalityOfTransmission = "seasonal",
                  currentPrevalence = "med",
                  bitingIndoors = "high",
                  bitingPeople = "low",
                  levelOfResistance = "80%",
                  itnUsage = "20%",
                  sprayInput = "0%")
  db <- mintr_test_db()
  expect_identical(
    db$get_prevalence(c(options, population = 1000)),
    db$get_prevalence(options))
  expect_identical(
    db$get_prevalence(c(options, population = 1000, metabolic = "yes")),
    db$get_prevalence(options))
  expect_error(
    db$get_prevalence(c(options, population = 1000, meta = "yes")),
    "Unexpected: meta")
})


test_that("throw error if accessing impossible data", {
  db <- mintr_test_db()
  expect_error(db$get_prevalence(list()),
               "Invalid value for 'names(options)'", fixed = TRUE)

  options <- list(seasonalityOfTransmission = "seasonal",
                  currentPrevalence = "med",
                  bitingIndoors = "high",
                  bitingPeople = "really-high",
                  levelOfResistance = "80%",
                  itnUsage = "20%",
                  sprayInput = "0%")
  expect_error(db$get_prevalence(options),
               "No matching value 'really-high' for option 'bitingPeople'")
})


test_that("baseline options", {
  opt <- mint_baseline_options()
  expect_type(opt, "list")
  expect_setequal(names(opt), c("index", "ignore"))
  expect_setequal(
    names(opt$index),
    c("seasonalityOfTransmission", "currentPrevalence", "bitingIndoors",
      "bitingPeople", "levelOfResistance", "itnUsage", "sprayInput"))
  expect_setequal(opt$ignore, c("population", "metabolic"))
})


test_that("index must conform to baseline options", {
  index <- mint_baseline_options()$index
  expect_error(
    mintr_db_check_index(index),
    "Invalid value for 'names(index)':\n  - Missing: index",
    fixed = TRUE)
  expect_error(
    mintr_db_check_index(index[names(index) != "itnUsage"]),
    "Invalid value for 'names(index)':\n  - Missing: itnUsage, index",
    fixed = TRUE)

  idx <- do.call(expand.grid, c(index, list(stringsAsFactors = FALSE)))
  idx$index <- seq_len(nrow(idx))
  expect_error(
    mintr_db_check_index(idx[1, ]),
    "Invalid value for 'index$seasonalityOfTransmission'",
    fixed = TRUE)
})


test_that("prevelance must conform", {
  index <- readRDS("data/index.rds")
  prevalence <- readRDS("data/prevalence.rds")

  expect_error(
    mintr_db_check_prevalence(index, prevalence[names(prevalence) != "irsUse"]),
    "Invalid value for 'names(prevalence)':\n  - Missing: irsUse",
    fixed = TRUE)

  expect_silent(mintr_db_check_prevalence(index, prevalence))

  i <- which(prevalence$intervention == "irs")[10]

  prevalence$intervention[i] <- "other"
  expect_error(
    mintr_db_check_prevalence(index, prevalence),
    "Interventions do not match expected values")

  prevalence$intervention[i] <- "No intervention"
  expect_error(
    mintr_db_check_prevalence(index, prevalence),
    "Interventions do not match expected values")
})


test_that("docker build filters files", {
  tmp <- tempfile()
  path_raw <- jsonlite::read_json(mintr_path("data.json"))$directory

  dir.create(tmp, FALSE, TRUE)
  file.copy(file.path("data", path_raw), tmp, recursive = TRUE)

  mintr_db_docker(tmp)

  expect_setequal(dir(tmp), c("index.rds", "prevalence.rds"))
})
