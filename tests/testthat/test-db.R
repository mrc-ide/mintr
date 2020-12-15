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
                  sprayInput = "0%",
                  metabolic = "yes",
                  population = 1000)
  d <- db$get_prevalence(options)
  expect_s3_class(d, "data.frame")
  expect_equal(nrow(d), 114 * 61)
  #expected_months <- 61
  #expected_none_rows <- 1
  #expected_llin_rows <- 10 # 10 possible netUse values
  #expected_irs_rows <- 6 # 6 possible irsUse values
  #expected_llin_irs_rows <- 60
  #expected_rows <- expected_none_rows + expected_irs_rows + 2 * expected_llin_rows + 2 * expected_llin_irs_rows
  #expect_equal(nrow(d), expected_rows * expected_months)
  expect_setequal(
    names(d),
    c("month", "netUse", "irsUse", "intervention", "value"))

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
                  currentPrevalence = "med",
                  bitingIndoors = "high",
                  bitingPeople = "low",
                  levelOfResistance = "80%",
                  itnUsage = "20%",
                  sprayInput = "0%",
                  metabolic = "yes",
                  population = 1000)
  d <- db$get_table(options)
  expect_s3_class(d, "data.frame")
  expect_equal(nrow(d), 114)
  #expected_none_rows <- 1
  #expected_llin_rows <- 10 # 10 possible netUse values
  #expected_irs_rows <- 6 # 6 possible irsUse values
  #expected_llin_irs_rows <- 60
  #expected_rows <- expected_none_rows + expected_irs_rows + 2 * expected_llin_rows + 2 * expected_llin_irs_rows
  #expect_equal(nrow(d), expected_rows)
  expect_setequal(
    names(d),
    c("netUse", "irsUse", "intervention", "prevYear1",
      "prevYear2", "prevYear3", "meanCases", "reductionInCases",
      "reductionInPrevalence", "casesAverted",
      "casesAvertedPer1000", "casesAvertedPer1000ErrorMinus",
      "casesAvertedPer1000ErrorPlus", "reductionInCasesErrorMinus",
      "reductionInCasesErrorPlus"))
})


test_that("error if db not present", {
  expect_error(
    mintr_db_open(tempfile()),
    "mintr database does not exist at '.+mintr.db'")
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
                  sprayInput = "0%",
                  population = 1000,
                  metabolic = "yes")
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

  expect_setequal(dir(tmp), c("index.rds", "prevalence.rds", "table.rds"))
})


test_that("Can scale table results by population", {
  db <- mintr_test_db()
  options <- list(seasonalityOfTransmission = "seasonal",
                  currentPrevalence = "med",
                  bitingIndoors = "high",
                  bitingPeople = "low",
                  levelOfResistance = "80%",
                  itnUsage = "20%",
                  sprayInput = "0%",
                  metabolic = "yes",
                  population = 10000)
  d1 <- db$get_table(options)
  d2 <- db$get_table(modifyList(options, list(population = 1000)))

  v <- setdiff(names(d1), "casesAverted")
  expect_equal(d2[v], d1[v])
  ## Due to rounding error, this is only approximate
  expect_equal(d2$casesAverted, d1$casesAverted / 10,
               tolerance = 0.001)
})


test_that("Can get non-metabolic table data", {
  db <- mintr_test_db()
  options <- list(seasonalityOfTransmission = "seasonal",
                  currentPrevalence = "med",
                  bitingIndoors = "high",
                  bitingPeople = "low",
                  levelOfResistance = "80%",
                  itnUsage = "20%",
                  sprayInput = "0%",
                  metabolic = "yes",
                  population = 1)

  cmp <- db$get_table(options)
  res <- db$get_table(modifyList(options, list(metabolic = "no")))
  expect_equal(dim(cmp), dim(res))
  expect_equal(names(cmp), names(res))
  expect_equal(res, mintr_db_transform_metabolic(cmp, "no"))
  cols <- setdiff(names(res), "intervention")
  expect_equal(res[res$intervention == "llin-pbo", cols],
               res[res$intervention == "llin", cols],
               check.attributes = FALSE)
  expect_equal(res[res$intervention == "irs-llin-pbo", cols],
               res[res$intervention == "irs-llin", cols],
               check.attributes = FALSE)
})


test_that("Can get non-metabolic prevalence data", {
  db <- mintr_test_db()
  options <- list(seasonalityOfTransmission = "seasonal",
                  currentPrevalence = "med",
                  bitingIndoors = "high",
                  bitingPeople = "low",
                  levelOfResistance = "80%",
                  itnUsage = "20%",
                  sprayInput = "0%",
                  metabolic = "yes",
                  population = 1)

  cmp <- db$get_prevalence(options)
  res <- db$get_prevalence(modifyList(options, list(metabolic = "no")))
  expect_equal(dim(cmp), dim(res))
  expect_equal(names(cmp), names(res))
  expect_equal(res, mintr_db_transform_metabolic(cmp, "no"))
  cols <- setdiff(names(res), "intervention")
  expect_equal(res[res$intervention == "llin-pbo", cols],
               res[res$intervention == "llin", cols],
               check.attributes = FALSE)
  expect_equal(res[res$intervention == "irs-llin-pbo", cols],
               res[res$intervention == "irs-llin", cols],
               check.attributes = FALSE)
})


check_not_applicable_values <- function(res) {
  #cols <- setdiff(names(res), c("intervention", "netUse", "irsUse"))
  #expect_equal(res[res$intervention == "llin" & res$netUse == 0, cols],
  #             res[res$intervention == "none", cols],
  #             check.attributes = FALSE)
  #expect_equal(res[res$intervention == "llin-pbo" & res$netUse == 0, cols],
  #             res[res$intervention == "none", cols],
  #             check.attributes = FALSE)
  #expect_equal(res[res$intervention == "irs" & res$irsUse == 0, cols],
  #             res[res$intervention == "none", cols],
  #             check.attributes = FALSE)
  #expect_equal(res[res$intervention == "irs-llin" & res$netUse == 0, cols],
  #             res[res$intervention == "irs", cols],
  #             check.attributes = FALSE)
  #expect_equal(res[res$intervention == "irs-llin-pbo" & res$netUse == 0, cols],
  #             res[res$intervention == "irs", cols],
  #             check.attributes = FALSE)
  #expect_equal(res[res$intervention == "irs-llin" & res$irsUse == 0, cols],
  #             res[res$intervention == "llin", cols],
  #             check.attributes = FALSE)
  #expect_equal(res[res$intervention == "irs-llin-pbo" & res$irsUse == 0, cols],
  #             res[res$intervention == "llin-pbo", cols],
  #             check.attributes = FALSE)

  expect_true(all(res[res$intervention == "none", "netUse"] == "n/a"))
  expect_true(all(res[res$intervention == "none", "irsUse"] == "n/a"))
  expect_true(all(res[res$intervention == "irs", "netUse"] == "n/a"))
  expect_true(all(res[res$intervention == "llin", "irsUse"] == "n/a"))
  expect_true(all(res[res$intervention == "llin-pbo", "irsUse"] == "n/a"))
}


test_that("Not applicable values are set correctly", {
  db <- mintr_test_db()
  options <- list(seasonalityOfTransmission = "seasonal",
                  currentPrevalence = "med",
                  bitingIndoors = "high",
                  bitingPeople = "low",
                  levelOfResistance = "80%",
                  itnUsage = "20%",
                  sprayInput = "0%",
                  metabolic = "yes",
                  population = 1)

  prev <- db$get_prevalence(options)
  check_not_applicable_values(prev)

  table <- db$get_table(options)
  check_not_applicable_values(table)
})
