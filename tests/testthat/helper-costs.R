get_input <- function() {
  list(population = 1000,
       procurePeoplePerNet = 1.8,
       priceNetStandard = 1.5,
       priceNetPBO = 2.5,
       priceDelivery = 2.75,
       procureBuffer = 7,
       priceIRSPerPerson = 2.5,
       casesAverted = 10,
       casesAvertedErrorPlus = 11,
       casesAvertedErrorMinus = 8,
       budgetAllZones = 1000)
}

get_expected_total_costs <- function() {
  input <- get_input()

  # setting these variables up to be as similar as possible to guidance
  # https://mrc-ide.myjetbrains.com/youtrack/issue/mrc-2083
  population <- input$population
  procurement_buffer <- (input$procureBuffer + 100) / 100
  cost_per_N1 <- input$priceNetStandard
  cost_per_N2 <- input$priceNetPBO
  price_NET_delivery <- input$priceDelivery
  price_IRS_delivery <- input$priceIRSPerPerson * population

  costs_N0 <- 0
  costs_N1 <- (price_NET_delivery + cost_per_N1) * (population / input$procurePeoplePerNet * procurement_buffer)
  costs_N2 <- (price_NET_delivery + cost_per_N2) * (population / input$procurePeoplePerNet * procurement_buffer)
  costs_S1 <- 3 * price_IRS_delivery
  costs_N1_S1 <- costs_N1 + costs_S1
  costs_N2_S1 <- costs_N2 + costs_S1

  list(costs_N0 = costs_N0,
       costs_N1 = costs_N1,
       costs_N2 = costs_N2,
       costs_S1 = costs_S1,
       costs_N1_S1 = costs_N1_S1,
       costs_N2_S1 = costs_N2_S1)
}
