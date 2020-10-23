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


test_that("building with overwrite replaces all files", {
  mintr_db_open("data", overwrite = FALSE) # ensure everything here
  files <- c("data/mintr.db", "data/index.rds", "data/prevalence.rds")
  old_time <- file.info(files)$mtime
  old_md5 <- tools::md5sum(files)

  msg <- testthat::capture_messages(mintr_db_open("data", overwrite = TRUE))

  expect_match(msg, "Processing index", all = FALSE)
  expect_match(msg, "Processing prevalence", all = FALSE)
  expect_match(msg, "Building database", all = FALSE)

  expect_true(all(file.info(files)$mtime > old_time))
  expect_equal(tools::md5sum(files), old_md5)
})


test_that("docker build filters files", {
  mock_mintr_db_open <- mockery::mock()

  tmp <- tempfile()
  dir.create(tmp)
  files <- dir("data", all.files = TRUE, no.. = TRUE, full.names = TRUE)
  file.copy(files, tmp, recursive = TRUE)
  with_mock(
    "mintr:::mintr_db_open" = mock_mintr_db_open,
    mintr_db_docker(tmp))

  expect_setequal(dir(tmp), c("index.rds", "prevalence.rds"))
  mockery::expect_called(mock_mintr_db_open, 1)
  expect_equal(mockery::mock_args(mock_mintr_db_open)[[1]], list(tmp))
})
