context("config")

get_input <- function() {
  list(population = 1000,
       procurePeoplePerNet = 1.8,
       priceNetStandard = 1.5,
       priceNetPBO = 2.5,
       priceDelivery = 2.75,
       procureBuffer = 7,
       priceIRSPerPerson = 2.5,
       casesAverted = 10)
}

get_expected_total_costs <- function() {
  input <- get_input()

  # setting these variables up to be as similar as possible to Ellie's original code
  # https://github.com/mrc-ide/shiny-malaria-UI/blob/master/server.R#L1148
  # for verification of correctness
  population <- input$population
  procurement_buffer <- (input$procureBuffer + 100) / 100
  cost_per_N0 <- input$priceNetStandard
  cost_per_N1 <- input$priceNetStandard
  cost_per_N2 <- input$priceNetPBO
  price_NET_delivery <- input$priceDelivery *
    population *
    procurement_buffer
  price_IRS_delivery <- input$priceIRSPerPerson * population

  costs_N0 <- cost_per_N0 * (population / input$procurePeoplePerNet) + 0
  costs_N1 <- cost_per_N1 * (population / input$procurePeoplePerNet) + price_NET_delivery
  costs_N2 <- cost_per_N2 * (population / input$procurePeoplePerNet) + price_NET_delivery
  costs_S1 <- cost_per_N0 * (population / input$procurePeoplePerNet) +
    0 +
    3 * price_IRS_delivery
  costs_N1_S1 <- cost_per_N1 * (population / input$procurePeoplePerNet) +
    price_NET_delivery +
    3 * price_IRS_delivery
  costs_N2_S1 <- cost_per_N2 * (population / input$procurePeoplePerNet) +
    price_NET_delivery +
    3 * price_IRS_delivery

  list(costs_N0 = costs_N0,
       costs_N1 = costs_N1,
       costs_N2 = costs_N2,
       costs_S1 = costs_S1,
       costs_N1_S1 = costs_N1_S1,
       costs_N2_S1 = costs_N2_S1)
}

get_incremental_increase_in_costs <- function() {
  total_costs <- get_expected_total_costs()
  baseline_cost <- as.list(rep(total_costs$costs_N0, 6))
  increase_in_costs <- mapply("-", total_costs, baseline_cost, SIMPLIFY = FALSE)
  increase_in_costs
}

get_costs_per_cases_averted <- function() {
  input <- get_input()
  total_costs <- get_expected_total_costs()
  lapply(total_costs, function(x) x/input$casesAverted)
}

evaluate <- function(formula) {
  input <- get_input()
  eval(parse(text = glue::glue(formula, .envir = input)))
}

test_that("efficacy vs costs graph config formulas give correct results", {
  json <- jsonlite::fromJSON(mintr_path("json/graph_cost_efficacy_config.json"))
  formulas <- json$series$y_formula
  costs <- get_expected_total_costs()

  none <- formulas[[1]]
  expect_equal(evaluate(none), costs$costs_N0)
  ITN <- formulas[[2]]
  expect_equal(evaluate(ITN), costs$costs_N1)
  PBO <- formulas[[3]]
  expect_equal(evaluate(PBO), costs$costs_N2)
  IRS <- formulas[[4]]
  expect_equal(evaluate(IRS), costs$costs_S1)
  ITN_IRS <- formulas[[5]]
  expect_equal(evaluate(ITN_IRS), costs$costs_N1_S1)
  PBO_IRS <- formulas[[6]]
  expect_equal(evaluate(PBO_IRS), costs$costs_N2_S1)
})

test_that("cases averted vs costs graph config formulas give correct results", {
  json <- jsonlite::fromJSON(mintr_path("json/graph_cost_cases_averted_config.json"))
  formulas <- json$series$y_formula
  costs <- get_expected_total_costs()

  none <- formulas[[1]]
  expect_equal(evaluate(none), costs$costs_N0)
  ITN <- formulas[[2]]
  expect_equal(evaluate(ITN), costs$costs_N1)
  PBO <- formulas[[3]]
  expect_equal(evaluate(PBO), costs$costs_N2)
  IRS <- formulas[[4]]
  expect_equal(evaluate(IRS), costs$costs_S1)
  ITN_IRS <- formulas[[5]]
  expect_equal(evaluate(ITN_IRS), costs$costs_N1_S1)
  PBO_IRS <- formulas[[6]]
  expect_equal(evaluate(PBO_IRS), costs$costs_N2_S1)
})

test_that("efficacy vs costs graph config contains valid intervention ids", {
  json <- jsonlite::fromJSON(mintr_path("json/graph_cost_efficacy_config.json"))
  ids <- json$series$id

  none <- ids[[1]]
  expect_equal(none, mint_intervention(0, 0, "std"))
  ITN <- ids[[2]]
  expect_equal(ITN, mint_intervention(1, 0, "std"))
  PBO <- ids[[3]]
  expect_equal(PBO, mint_intervention(1, 0, "pto"))
  IRS <- ids[[4]]
  expect_equal(IRS, mint_intervention(0, 1, "pto"))
  ITN_IRS <- ids[[5]]
  expect_equal(ITN_IRS, mint_intervention(1, 1, "std"))
  PBO_IRS <- ids[[6]]
  expect_equal(PBO_IRS, mint_intervention(1, 1, "pto"))
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
  IRS <- ids[[4]]
  expect_equal(IRS, mint_intervention(0, 1, "pto"))
  ITN_IRS <- ids[[5]]
  expect_equal(ITN_IRS, mint_intervention(1, 1, "std"))
  PBO_IRS <- ids[[6]]
  expect_equal(PBO_IRS, mint_intervention(1, 1, "pto"))
})

test_that("cases averted graph config contains valid intervention ids", {
  json <- jsonlite::fromJSON(mintr_path("json/graph_cases_averted_config.json"))
  x <- json$series$x
  ids <- json$series$id

  ITN <- ids[[1]]
  expect_equal(ITN, mint_intervention(1, 0, "std"))
  PBO <- ids[[2]]
  expect_equal(PBO, mint_intervention(1, 0, "pto"))
  IRS <- ids[[3]]
  expect_equal(IRS, mint_intervention(0, 1, "pto"))
  ITN_IRS <- ids[[4]]
  expect_equal(ITN_IRS, mint_intervention(1, 1, "std"))
  PBO_IRS <- ids[[5]]
  expect_equal(PBO_IRS, mint_intervention(1, 1, "pto"))

  ITN <- x[[1]]
  expect_equal(ITN, mint_intervention(1, 0, "std"))
  PBO <- x[[2]]
  expect_equal(PBO, mint_intervention(1, 0, "pto"))
  IRS <- x[[3]]
  expect_equal(IRS, mint_intervention(0, 1, "pto"))
  ITN_IRS <- x[[4]]
  expect_equal(ITN_IRS, mint_intervention(1, 1, "std"))
  PBO_IRS <- x[[5]]
  expect_equal(PBO_IRS, mint_intervention(1, 1, "pto"))

  tick_vals <- json$layout$xaxis$tickvals
  expect_equal(tick_vals, c(ITN, PBO, IRS, ITN_IRS, PBO_IRS))

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
  IRS <- ids[[4]]
  expect_equal(IRS, mint_intervention(0, 1, "pto"))
  ITN_IRS <- ids[[5]]
  expect_equal(ITN_IRS, mint_intervention(1, 1, "std"))
  PBO_IRS <- ids[[6]]
  expect_equal(PBO_IRS, mint_intervention(1, 1, "pto"))
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
  IRS <- ids[[4]]
  expect_equal(IRS, mint_intervention(0, 1, "pto"))
  ITN_IRS <- ids[[5]]
  expect_equal(ITN_IRS, mint_intervention(1, 1, "std"))
  PBO_IRS <- ids[[6]]
  expect_equal(PBO_IRS, mint_intervention(1, 1, "pto"))

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
  IRS <- formulas[[4]]
  expect_equal(evaluate(IRS), costs$costs_S1)
  ITN_IRS <- formulas[[5]]
  expect_equal(evaluate(ITN_IRS), costs$costs_N1_S1)
  PBO_IRS <- formulas[[6]]
  expect_equal(evaluate(PBO_IRS), costs$costs_N2_S1)
})

test_that("cost table config formulas give correct results for incremental increase in costs", {
  json <- jsonlite::fromJSON(mintr_path("json/table_cost_config.json"))
  formulas <- json$valueTransform[6,]
  costs <- get_incremental_increase_in_costs()

  none <- formulas[[1]]
  expect_equal(evaluate(none), costs$costs_N0)
  ITN <- formulas[[2]]
  expect_equal(evaluate(ITN), costs$costs_N1)
  PBO <- formulas[[3]]
  expect_equal(evaluate(PBO), costs$costs_N2)
  IRS <- formulas[[4]]
  expect_equal(evaluate(IRS), costs$costs_S1)
  ITN_IRS <- formulas[[5]]
  expect_equal(evaluate(ITN_IRS), costs$costs_N1_S1)
  PBO_IRS <- formulas[[6]]
  expect_equal(evaluate(PBO_IRS), costs$costs_N2_S1)
})

test_that("cost table config formulas give correct results for costs per cases averted", {
  json <- jsonlite::fromJSON(mintr_path("json/table_cost_config.json"))
  formulas <- json$valueTransform[7,]
  costs <- get_costs_per_cases_averted()

  none <- formulas[[1]]
  expect_equal(evaluate(none), "reference")
  ITN <- formulas[[2]]
  expect_equal(evaluate(ITN), costs$costs_N1)
  PBO <- formulas[[3]]
  expect_equal(evaluate(PBO), costs$costs_N2)
  IRS <- formulas[[4]]
  expect_equal(evaluate(IRS), costs$costs_S1)
  ITN_IRS <- formulas[[5]]
  expect_equal(evaluate(ITN_IRS), costs$costs_N1_S1)
  PBO_IRS <- formulas[[6]]
  expect_equal(evaluate(PBO_IRS), costs$costs_N2_S1)

})
