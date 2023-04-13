get_input <- function() {
  list(population = 10000,
       procurePeoplePerNet = 1.8,
       priceNetStandard = 1.5,
       priceNetPBO = 2.5,
       priceNetPyrrole = 3.2,
       priceDelivery = 2.75,
       procureBuffer = 7,
       priceIRSPerPerson = 2.5,
       casesAverted = 100,
       casesAvertedErrorPlus = 110,
       casesAvertedErrorMinus = 80,
       casesAvertedPer1000 = 10,
       casesAvertedPer1000ErrorPlus = 11,
       casesAvertedPer1000ErrorMinus = 8,
       budgetAllZones = 1000)
}

get_costs <- function(numberOfPeople) {
  input <- get_input()
  
  procurement_buffer <- (input$procureBuffer + 100) / 100
  cost_per_N1 <- input$priceNetStandard
  cost_per_N2 <- input$priceNetPBO
  cost_per_N3 <- input$priceNetPyrrole
  price_NET_delivery <- input$priceDelivery
  price_IRS_delivery <- input$priceIRSPerPerson * numberOfPeople
  
  costs_N0 <- 0
  costs_N1 <- (price_NET_delivery + cost_per_N1) * (numberOfPeople / input$procurePeoplePerNet * procurement_buffer)
  costs_N2 <- (price_NET_delivery + cost_per_N2) * (numberOfPeople / input$procurePeoplePerNet * procurement_buffer)
  costs_N3 <- (price_NET_delivery + cost_per_N3) * (numberOfPeople / input$procurePeoplePerNet * procurement_buffer)
  costs_S1 <- 3 * price_IRS_delivery
  costs_N1_S1 <- costs_N1 + costs_S1
  costs_N2_S1 <- costs_N2 + costs_S1
  costs_N3_S1 <- costs_N3 + costs_S1
  
  list(costs_N0 = costs_N0,
       costs_N1 = costs_N1,
       costs_N2 = costs_N2,
       costs_N3 = costs_N3,
       costs_S1 = costs_S1,
       costs_N1_S1 = costs_N1_S1,
       costs_N2_S1 = costs_N2_S1,
       costs_N3_S1 = costs_N3_S1)
}

get_expected_total_costs <- function() {
  input <- get_input()
  get_costs(input$population)
}

get_expected_costs_per_1000 <- function() {
  get_costs(1000)
}
