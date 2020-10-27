context("config")

input <- list(population = 1000,
                      procurePeoplePerNet = 1.8,
                      priceNetStandard = 1.5,
                      priceNetPBO = 2.5,
                      priceDelivery = 2.75,
                      procureBuffer = 7,
                      priceIRSPerPerson = 2.5)

# setting these variables up to be as similar as possible to Ellie's original code
# https://github.com/mrc-ide/shiny-malaria-UI/blob/master/server.R#L1148
# for verification of correctness
population <- input$population
procurement_buffer <- (input$procureBuffer + 100) / 100
cost_per_N0 <- input$priceNetStandard
cost_per_N1 <- input$priceNetStandard
cost_per_N2 <- input$priceNetPBO
price_NET_delivery <- input$priceDelivery *  population *  procurement_buffer
price_IRS_delivery <- input$priceIRSPerPerson * population

costs_N0 <- cost_per_N0 * (population/input$procurePeoplePerNet) + 0
costs_N1 <- cost_per_N1 * (population/input$procurePeoplePerNet) + price_NET_delivery
costs_N2 <- cost_per_N2 * (population/input$procurePeoplePerNet) + price_NET_delivery
costs_S1 <- cost_per_N0 * (population/input$procurePeoplePerNet) + 0 + 3 * price_IRS_delivery
costs_N1_S1 <- cost_per_N1 * (population/input$procurePeoplePerNet) + price_NET_delivery + 3 * price_IRS_delivery
costs_N2_S1 <- cost_per_N2 * (population/input$procurePeoplePerNet) + price_NET_delivery + 3 * price_IRS_delivery

evaluate <- function(formula) {
  formula <- stringr::str_replace_all(formula, stringr::fixed("{"), "${")
  formula <- stringr::str_interp(formula, input)
  eval(parse(text = formula))
}

test_that("efficacy vs costs graph config formulas give correct results", {
  json <- jsonlite::fromJSON(mintr_path("json/graph_cost_efficacy_config.json"))
  formulas <- json$series$y_formula
  none <- formulas[[1]]
  expect_equal(evaluate(none), costs_N0)
  ITN <- formulas[[2]]
  expect_equal(evaluate(ITN), costs_N1)
  PBO <- formulas[[3]]
  expect_equal(evaluate(PBO), costs_N2)
  IRS <- formulas[[4]]
  expect_equal(evaluate(IRS), costs_S1)
  ITN_IRS <- formulas[[5]]
  expect_equal(evaluate(ITN_IRS), costs_N1_S1)
  PBO_IRS <- formulas[[6]]
  expect_equal(evaluate(PBO_IRS), costs_N2_S1)
})

test_that("cases averted vs costs graph config formulas give correct results", {
  json <- jsonlite::fromJSON(mintr_path("json/graph_cost_cases_averted_config.json"))
  formulas <- json$series$y_formula
  none <- formulas[[1]]
  expect_equal(evaluate(none), costs_N0)
  ITN <- formulas[[2]]
  expect_equal(evaluate(ITN), costs_N1)
  PBO <- formulas[[3]]
  expect_equal(evaluate(PBO), costs_N2)
  IRS <- formulas[[4]]
  expect_equal(evaluate(IRS), costs_S1)
  ITN_IRS <- formulas[[5]]
  expect_equal(evaluate(ITN_IRS), costs_N1_S1)
  PBO_IRS <- formulas[[6]]
  expect_equal(evaluate(PBO_IRS), costs_N2_S1)
})
