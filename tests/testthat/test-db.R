context("db")

test_that("Can create db", {
  db <- mintr_test_db()
  expect_error(db$get_prevalence(list()),
               "Invalid value for 'names(options)'", fixed = TRUE)
  options <- list(seasonalityOfTransmission = "seasonal",
                  currentPrevalence = "30%",
                  bitingIndoors = "high",
                  bitingPeople = "low",
                  levelOfResistance = "80%",
                  itnUsage = "20%",
                  sprayInput = "80%",
                  population = 1000)
  d <- db$get_prevalence(options)
  expect_s3_class(d, "data.frame")
  expect_equal(nrow(d), 8400) # 50 months * 168 combinations
  expect_setequal(
    names(d),
    c("month", "netUse", "irsUse", "intervention", "value"))
  expect_equal(max(d$month), 36) # should filter out the year 4 values

  impact <- db$get_impact_docs()
  cost <- db$get_cost_docs()
  expect_is(impact, "json")
  expect_is(cost, "json")

  expect_true(grepl("<strong>Impact</strong>", impact))
  expect_true(grepl("<strong>Cost Effectiveness</strong>", cost))
})


test_that("Can read table data", {
  db <- mintr_test_db()
  options <- list(seasonalityOfTransmission = "seasonal",
                  currentPrevalence = "30%",
                  bitingIndoors = "high",
                  bitingPeople = "low",
                  levelOfResistance = "80%",
                  itnUsage = "20%",
                  sprayInput = "0%",
                  population = 1000)
  d <- db$get_table(options)
  expect_s3_class(d, "data.frame")
  expect_equal(nrow(d), 168)
  expect_setequal(
    names(d),
    c("netUse", "irsUse", "intervention",
      "casesAverted", "casesAvertedErrorMinus", "casesAvertedErrorPlus",
      "casesAvertedPer1000", "casesAvertedPer1000ErrorMinus", "casesAvertedPer1000ErrorPlus",
      "prevYear1", "prevYear1ErrorMinus", "prevYear1ErrorPlus",
      "prevYear2", "prevYear2ErrorMinus", "prevYear2ErrorPlus",
      "prevYear3", "prevYear3ErrorMinus", "prevYear3ErrorPlus",
      "reductionInPrevalence", "reductionInPrevalenceErrorMinus", "reductionInPrevalenceErrorPlus",
      "reductionInCases", "reductionInCasesErrorMinus", "reductionInCasesErrorPlus",
      "meanCases", "meanCasesErrorMinus", "meanCasesErrorPlus"))
})


test_that("error if db not present", {
  expect_error(
    mintr_db_open(tempfile()),
    "mintr database does not exist at '.+index.rds'")
})


test_that("throw error if accessing impossible data", {
  db <- mintr_test_db()
  expect_error(db$get_prevalence(list()),
               "Invalid value for 'names(options)'", fixed = TRUE)

  options <- list(seasonalityOfTransmission = "seasonal",
                  currentPrevalence = "30%",
                  bitingIndoors = "high",
                  bitingPeople = "really-high",
                  levelOfResistance = "80%",
                  itnUsage = "20%",
                  sprayInput = "0%",
                  population = 1000)
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
  expect_setequal(opt$ignore, c("population"))
})

test_that("Can scale table results by population", {
  db <- mintr_test_db()
  options <- list(seasonalityOfTransmission = "seasonal",
                  currentPrevalence = "30%",
                  bitingIndoors = "high",
                  bitingPeople = "low",
                  levelOfResistance = "80%",
                  itnUsage = "20%",
                  sprayInput = "0%",
                  population = 10000)
  d1 <- db$get_table(options)
  d2 <- db$get_table(modifyList(options, list(population = 1000)))

  v <- setdiff(names(d1), c("casesAverted", "casesAvertedErrorMinus", "casesAvertedErrorPlus"))
  expect_equal(d2[v], d1[v])
  ## Due to rounding error, this is only approximate
  expect_equal(d2$casesAverted, d1$casesAverted / 10,
               tolerance = 0.01)
})


test_that("Confidence bounds are ordered and include the mean", {
  db <- mintr_test_db()
  ## This is a scenario where low > high > mean in the 20201217 dataset
  options <- list(seasonalityOfTransmission = "seasonal",
                  currentPrevalence = "5%",
                  bitingIndoors = "high",
                  bitingPeople = "low",
                  levelOfResistance = "0%",
                  itnUsage = "0%",
                  sprayInput = "0%",
                  population = 1000)
  d <- db$get_table(options)
  expect_setequal(d$casesAvertedErrorPlus >= d$casesAverted, TRUE)
  expect_setequal(d$casesAverted >= d$casesAvertedErrorMinus, TRUE)
})

expect_interventions <- function (data) {
  expect_true(all(data$intervention %in% c("none", "irs", "llin", "llin-pbo", "pyrrole-pbo", "irs-llin", "irs-llin-pbo", "irs-pyrrole-pbo")))
}

expect_net_use <- function (data) {
  expect_true(all(data$netUse %in% c("n/a", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1")))
}

expect_irs_use <- function (data) {
  expect_true(all(data$irsUse %in% c("n/a", "0.6", "0.7", "0.8", "0.9", "1")))
}

expect_proportion <- function (data, col) {
  expect_true(col %in% names(data))
  expect_true(all(data[col] >= 0) && all(data[col] <= 1))
}

expect_proportion_with_errors <- function (data, col) {
  expect_proportion(data, col)
  expect_proportion(data, paste(col, "ErrorPlus", sep=""))
  expect_proportion(data, paste(col, "ErrorMinus", sep=""))
}

expect_whole_number <- function (data, col) {
  expect_true(col %in% names(data))
  expect_true(all((data[col] >= 0) && (data[col] %% 1 == 0)))
}

expect_whole_number_with_errors <- function (data, col) {
  expect_whole_number(data, col)
  expect_whole_number(data, paste(col, "ErrorPlus", sep=""))
  expect_whole_number(data, paste(col, "ErrorMinus", sep=""))
}


test_that("Can get table data", {
  db <- mintr_test_db()
  options <- list(seasonalityOfTransmission = "seasonal",
                  currentPrevalence = "30%",
                  bitingIndoors = "high",
                  bitingPeople = "low",
                  levelOfResistance = "80%",
                  itnUsage = "20%",
                  sprayInput = "0%",
                  population = 1)

  res <- db$get_table(options)
  expect_interventions(res)
  expect_net_use(res)
  expect_irs_use(res)
  expect_proportion_with_errors(res, "prevYear1")
  expect_proportion_with_errors(res, "prevYear2")
  expect_proportion_with_errors(res, "prevYear3")
  expect_whole_number_with_errors(res, "casesAvertedPer1000")
  expect_proportion_with_errors(res, "meanCases")
})


test_that("Can get prevalence data", {
  db <- mintr_test_db()
  options <- list(seasonalityOfTransmission = "seasonal",
                  currentPrevalence = "30%",
                  bitingIndoors = "high",
                  bitingPeople = "low",
                  levelOfResistance = "80%",
                  itnUsage = "20%",
                  sprayInput = "0%",
                  population = 1)

  res <- db$get_prevalence(options)
  expect_true(all(res$month >= -13) && all(res$month <= 47))
  expect_proportion(res, "value")
  expect_net_use(res)
  expect_irs_use(res)
  expect_interventions(res)
})


check_not_applicable_values <- function(res) {
  expect_true(all(res[res$intervention == "none", "netUse"] == "n/a"))
  expect_true(all(res[res$intervention == "none", "irsUse"] == "n/a"))
  expect_true(all(res[res$intervention == "irs", "netUse"] == "n/a"))
  expect_true(all(res[res$intervention == "llin", "irsUse"] == "n/a"))
  expect_true(all(res[res$intervention == "llin-pbo", "irsUse"] == "n/a"))
  expect_true(all(res[res$intervention == "pyrrole-pbo", "irsUse"] == "n/a"))
}


test_that("Not applicable values are set correctly", {
  db <- mintr_test_db()
  options <- list(seasonalityOfTransmission = "seasonal",
                  currentPrevalence = "30%",
                  bitingIndoors = "high",
                  bitingPeople = "low",
                  levelOfResistance = "80%",
                  itnUsage = "20%",
                  sprayInput = "0%",
                  population = 1)

  prev <- db$get_prevalence(options)
  check_not_applicable_values(prev)

  table <- db$get_table(options)
  check_not_applicable_values(table)
})

test_that("can download the db on request", {
  skip_if_offline()
  p <- tempfile()
  on.exit(unlink(p, recursive = TRUE))
  res <- mintr_db_download(p, quiet = TRUE)
  expect_equal(basename(res), mintr_data_version())
  expect_setequal(
    dir(res),
    c("hash.rds", "ignore.rds", "index.rds", "prevalence", "table"))
})
