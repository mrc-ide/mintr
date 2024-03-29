context("config")

get_costs_per_cases_averted <- function(casesAvertedField = "casesAverted") {
  input <- get_input()
  total_costs <- get_expected_total_costs()
  lapply(total_costs, function(x) x/(input[[casesAvertedField]] * 3))
}

evaluate <- function(formula) {
  input <- get_input()
  eval(parse(text = glue::glue(formula, .envir = input)))
}

validate_costs_per_case <- function(formulas, costs) {
  ITN <- formulas[[1]]
  expect_equal(evaluate(ITN), costs$costs_N1)
  PBO <- formulas[[2]]
  expect_equal(evaluate(PBO), costs$costs_N2)
  pyrrole <- formulas[[3]]
  expect_equal(evaluate(pyrrole), costs$costs_N3)
  IRS <- formulas[[4]]
  expect_equal(evaluate(IRS), costs$costs_S1)
  ITN_IRS <- formulas[[5]]
  expect_equal(evaluate(ITN_IRS), costs$costs_N1_S1)
  PBO_IRS <- formulas[[6]]
  expect_equal(evaluate(PBO_IRS), costs$costs_N2_S1)
  pyrrole_IRS <- formulas[[7]]
  expect_equal(evaluate(pyrrole_IRS), costs$costs_N3_S1)
}

test_that("cost per case graph config formulas give correct results", {
  json <- jsonlite::fromJSON(mintr_path("json/graph_cost_per_case_config.json"))
  validate_costs_per_case(json$series$y_formula,         get_costs_per_cases_averted("casesAverted"))
  # cost per case is inversely proportional to cases averted
  validate_costs_per_case(json$series$error_y$cols,      get_costs_per_cases_averted("casesAvertedErrorMinus"))
  validate_costs_per_case(json$series$error_y$colsminus, get_costs_per_cases_averted("casesAvertedErrorPlus"))
})

test_that("cases averted vs costs graph config series formulas give correct results", {
  json <- jsonlite::fromJSON(mintr_path("json/graph_cost_cases_averted_config.json"))
  formulas <- json$series$y_formula
  costs <- get_expected_costs_per_1000()

  none <- formulas[[1]]
  expect_equal(evaluate(none), costs$costs_N0)
  ITN <- formulas[[2]]
  expect_equal(evaluate(ITN), costs$costs_N1)
  PBO <- formulas[[3]]
  expect_equal(evaluate(PBO), costs$costs_N2)
  pyrrole <- formulas[[4]]
  expect_equal(evaluate(pyrrole), costs$costs_N3)
  IRS <- formulas[[5]]
  expect_equal(evaluate(IRS), costs$costs_S1)
  ITN_IRS <- formulas[[6]]
  expect_equal(evaluate(ITN_IRS), costs$costs_N1_S1)
  PBO_IRS <- formulas[[7]]
  expect_equal(evaluate(PBO_IRS), costs$costs_N2_S1)
  pyrrole_IRS <- formulas[[8]]
  expect_equal(evaluate(pyrrole_IRS), costs$costs_N3_S1)
})

test_that("cases averted vs costs graph config series x error formulas give correct results", {
  json <- jsonlite::fromJSON(mintr_path("json/graph_cost_cases_averted_config.json"))
  plus_formulas <- json$series$error_x$cols
  minus_formulas <- json$series$error_x$cols_minus
  input <- get_input()
  
  lapply(plus_formulas, function(x) expect_equal(evaluate(x), input$casesAvertedPer1000ErrorPlus * 3))
  lapply(minus_formulas, function(x) expect_equal(evaluate(x), input$casesAvertedPer1000ErrorMinus * 3))
})

test_that("cases averted vs costs graph config x_formula gives correct results", {
  json <- jsonlite::fromJSON(mintr_path("json/graph_cost_cases_averted_config.json"))
  inputs <- get_input()
  x_formula <- json$metadata$x_formula
  expect_equal(evaluate(x_formula), inputs$casesAvertedPer1000 * 3)
})

test_that("cost per case graph config contains valid intervention ids", {
  json <- jsonlite::fromJSON(mintr_path("json/graph_cost_per_case_config.json"))
  ids <- json$series$id

  ITN <- ids[[1]]
  expect_equal(ITN, mint_intervention(1, 0, "std"))
  PBO <- ids[[2]]
  expect_equal(PBO, mint_intervention(1, 0, "pto"))
  pyrrole <- ids[[3]]
  expect_equal(pyrrole, mint_intervention(1, 0, "ig2"))
  IRS <- ids[[4]]
  expect_equal(IRS, mint_intervention(0, 1, "pto"))
  ITN_IRS <- ids[[5]]
  expect_equal(ITN_IRS, mint_intervention(1, 1, "std"))
  PBO_IRS <- ids[[6]]
  expect_equal(PBO_IRS, mint_intervention(1, 1, "pto"))
  pyrrole_IRS <- ids[[7]]
  expect_equal(pyrrole_IRS, mint_intervention(1, 1, "ig2"))
})

test_that("cases averted vs costs graph config contains valid intervention ids", {
  json <- jsonlite::fromJSON(mintr_path("json/graph_cost_cases_averted_config.json"))
  ids <- json$series$id

  none <- ids[[1]]
  expect_equal(none, mint_intervention(0, 0, "std"))
  ITN <- ids[[2]]
  expect_equal(ITN, mint_intervention(1, 0, "std"))
  PBO <- ids[[3]]
  expect_equal(PBO, mint_intervention(1, 0, "pto"))
  pyrrole <- ids[[4]]
  expect_equal(pyrrole, mint_intervention(1, 0, "ig2"))
  IRS <- ids[[5]]
  expect_equal(IRS, mint_intervention(0, 1, "pto"))
  ITN_IRS <- ids[[6]]
  expect_equal(ITN_IRS, mint_intervention(1, 1, "std"))
  PBO_IRS <- ids[[7]]
  expect_equal(PBO_IRS, mint_intervention(1, 1, "pto"))
  pyrrole_IRS <- ids[[8]]
  expect_equal(pyrrole_IRS, mint_intervention(1, 1, "ig2"))
})

test_that("cases averted graph config contains valid intervention ids", {
  json <- jsonlite::fromJSON(mintr_path("json/graph_cases_averted_config.json"))
  x <- json$series$x
  ids <- json$series$id

  ITN <- ids[[1]]
  expect_equal(ITN, mint_intervention(1, 0, "std"))
  PBO <- ids[[2]]
  expect_equal(PBO, mint_intervention(1, 0, "pto"))
  pyrrole <- ids[[3]]
  expect_equal(pyrrole, mint_intervention(1, 0, "ig2"))
  IRS <- ids[[4]]
  expect_equal(IRS, mint_intervention(0, 1, "pto"))
  ITN_IRS <- ids[[5]]
  expect_equal(ITN_IRS, mint_intervention(1, 1, "std"))
  PBO_IRS <- ids[[6]]
  expect_equal(PBO_IRS, mint_intervention(1, 1, "pto"))
  pyrrole_IRS <- ids[[7]]
  expect_equal(pyrrole_IRS, mint_intervention(1, 1, "ig2"))

  ITN <- x[[1]]
  expect_equal(ITN, mint_intervention(1, 0, "std"))
  PBO <- x[[2]]
  expect_equal(PBO, mint_intervention(1, 0, "pto"))
  pyrrole <- x[[3]]
  expect_equal(pyrrole, mint_intervention(1, 0, "ig2"))
  IRS <- x[[4]]
  expect_equal(IRS, mint_intervention(0, 1, "pto"))
  ITN_IRS <- x[[5]]
  expect_equal(ITN_IRS, mint_intervention(1, 1, "std"))
  PBO_IRS <- x[[6]]
  expect_equal(PBO_IRS, mint_intervention(1, 1, "pto"))
  pyrrole_IRS <- x[[7]]
  expect_equal(pyrrole_IRS, mint_intervention(1, 1, "ig2"))

  tick_vals <- json$layout$xaxis$tickvals
  expect_equal(tick_vals, c(ITN, PBO, pyrrole, IRS, ITN_IRS, PBO_IRS, pyrrole_IRS))
})

test_that("prevalence graph config containe valid intervention ids", {
  json <- jsonlite::fromJSON(mintr_path("json/graph_prevalence_config.json"))
  ids <- json$series$id

  none <- ids[[1]]
  expect_equal(none, mint_intervention(0, 0, "std"))
  ITN <- ids[[2]]
  expect_equal(ITN, mint_intervention(1, 0, "std"))
  PBO <- ids[[3]]
  expect_equal(PBO, mint_intervention(1, 0, "pto"))
  pyrrole <- ids[[4]]
  expect_equal(pyrrole, mint_intervention(1, 0, "ig2"))
  IRS <- ids[[5]]
  expect_equal(IRS, mint_intervention(0, 1, "pto"))
  ITN_IRS <- ids[[6]]
  expect_equal(ITN_IRS, mint_intervention(1, 1, "std"))
  PBO_IRS <- ids[[7]]
  expect_equal(PBO_IRS, mint_intervention(1, 1, "pto"))
  pyrrole_IRS <- ids[[8]]
  expect_equal(pyrrole_IRS, mint_intervention(1, 1, "ig2"))
})

test_that("impact table config contains valid intervention ids", {
  json <- jsonlite::fromJSON(mintr_path("json/table_impact_config.json"))

  ids <- names(json$valueTransform)
  none <- ids[[1]]
  expect_equal(none, mint_intervention(0, 0, "std"))
  ITN <- ids[[2]]
  expect_equal(ITN, mint_intervention(1, 0, "std"))
  PBO <- ids[[3]]
  expect_equal(PBO, mint_intervention(1, 0, "pto"))
  pyrrole <- ids[[4]]
  expect_equal(pyrrole, mint_intervention(1, 0, "ig2"))
  IRS <- ids[[5]]
  expect_equal(IRS, mint_intervention(0, 1, "pto"))
  ITN_IRS <- ids[[6]]
  expect_equal(ITN_IRS, mint_intervention(1, 1, "std"))
  PBO_IRS <- ids[[7]]
  expect_equal(PBO_IRS, mint_intervention(1, 1, "pto"))
  pyrrole_IRS <- ids[[8]]
  expect_equal(pyrrole_IRS, mint_intervention(1, 1, "ig2"))
})

test_that("cost table config contains valid intervention ids", {
  json <- jsonlite::fromJSON(mintr_path("json/table_cost_config.json"))

  ids <- names(json$valueTransform)
  none <- ids[[1]]
  expect_equal(none, mint_intervention(0, 0, "std"))
  ITN <- ids[[2]]
  expect_equal(ITN, mint_intervention(1, 0, "std"))
  PBO <- ids[[3]]
  expect_equal(PBO, mint_intervention(1, 0, "pto"))
  pyrrole <- ids[[4]]
  expect_equal(pyrrole, mint_intervention(1, 0, "ig2"))
  IRS <- ids[[5]]
  expect_equal(IRS, mint_intervention(0, 1, "pto"))
  ITN_IRS <- ids[[6]]
  expect_equal(ITN_IRS, mint_intervention(1, 1, "std"))
  PBO_IRS <- ids[[7]]
  expect_equal(PBO_IRS, mint_intervention(1, 1, "pto"))
  pyrrole_IRS <- ids[[8]]
  expect_equal(pyrrole_IRS, mint_intervention(1, 1, "ig2"))
})

test_that("cost table config formulas give correct results for total costs", {
  json <- jsonlite::fromJSON(mintr_path("json/table_cost_config.json"))
  formulas <- json$valueTransform[5,]
  costs <- get_expected_total_costs()

  none <- formulas[[1]]
  expect_equal(evaluate(none), costs$costs_N0)
  ITN <- formulas[[2]]
  expect_equal(evaluate(ITN), costs$costs_N1)
  PBO <- formulas[[3]]
  expect_equal(evaluate(PBO), costs$costs_N2)
  pyrrole <- formulas[[4]]
  expect_equal(evaluate(pyrrole), costs$costs_N3)
  IRS <- formulas[[5]]
  expect_equal(evaluate(IRS), costs$costs_S1)
  ITN_IRS <- formulas[[6]]
  expect_equal(evaluate(ITN_IRS), costs$costs_N1_S1)
  PBO_IRS <- formulas[[7]]
  expect_equal(evaluate(PBO_IRS), costs$costs_N2_S1)
  pyrrole_IRS <- formulas[[8]]
  expect_equal(evaluate(pyrrole_IRS), costs$costs_N3_S1)
})

validate_costs_per_cases_averted <- function(formulas, costs) {
  none <- formulas[[1]]
  expect_equal(evaluate(none), "reference")
  ITN <- formulas[[2]]
  expect_equal(evaluate(ITN), costs$costs_N1)
  PBO <- formulas[[3]]
  expect_equal(evaluate(PBO), costs$costs_N2)
  pyrrole <- formulas[[4]]
  expect_equal(evaluate(pyrrole), costs$costs_N3)
  IRS <- formulas[[5]]
  expect_equal(evaluate(IRS), costs$costs_S1)
  ITN_IRS <- formulas[[6]]
  expect_equal(evaluate(ITN_IRS), costs$costs_N1_S1)
  PBO_IRS <- formulas[[7]]
  expect_equal(evaluate(PBO_IRS), costs$costs_N2_S1)
  pyrrole_IRS <- formulas[[8]]
  expect_equal(evaluate(pyrrole_IRS), costs$costs_N3_S1)
}

test_that("cost table config formulas give correct results for costs per cases averted", {
  json <- jsonlite::fromJSON(mintr_path("json/table_cost_config.json"))
  validate_costs_per_cases_averted(json$valueTransform[6,], get_costs_per_cases_averted("casesAverted"))
  validate_costs_per_cases_averted(json$error$plus$valueTransform[6,], get_costs_per_cases_averted("casesAvertedErrorMinus"))
  validate_costs_per_cases_averted(json$error$minus$valueTransform[6,], get_costs_per_cases_averted("casesAvertedErrorPlus"))
})
