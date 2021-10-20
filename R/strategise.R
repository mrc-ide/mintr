get_cost <- function(baseline_settings, intervention_settings, intervention) {
  population <- baseline_settings$population
  procurement_buffer <- (intervention_settings$procureBuffer + 100) / 100
  cost_per_net_llin <- intervention_settings$priceNetStandard
  cost_per_net_pbo <- intervention_settings$priceNetPBO
  cost_delivery_per_net <- intervention_settings$priceDelivery
  people_per_net <- intervention_settings$procurePeoplePerNet
  cost_irs_per_person <- intervention_settings$priceIRSPerPerson
  switch(
    intervention,
    "none" = 0,
    "llin" = (cost_delivery_per_net + cost_per_net_llin) * (population / people_per_net * procurement_buffer),
    "llin-pbo" = (cost_delivery_per_net + cost_per_net_pbo) * (population / people_per_net * procurement_buffer),
    "irs" = 3 * cost_irs_per_person * population,
    "irs-llin" = (cost_delivery_per_net + cost_per_net_llin) * (population / people_per_net * procurement_buffer) + 3 * cost_irs_per_person * population,
    "irs-llin-pbo" = (cost_delivery_per_net + cost_per_net_pbo) * (population / people_per_net * procurement_buffer) + 3 * cost_irs_per_person * population
  )
}

get_intervention_data <- function(baseline_settings, intervention_settings, db) {
  table <- db$get_table(baseline_settings)
  rows <- table$intervention == "none"
  if (intervention_settings$netUse != "0") {
    rows <- rows | (
      table$intervention %in% c("llin", "llin-pbo") &
      table$netUse == intervention_settings$netUse &
      table$irsUse == "n/a"
    )
  }
  if (intervention_settings$irsUse != "0") {
    rows <- rows | (
      table$intervention == "irs" &
      table$netUse == "n/a" &
      table$irsUse == intervention_settings$irsUse
    )
  }
  if (intervention_settings$netUse != "0"
    && intervention_settings$irsUse != "0") {
    rows <- rows | (
      table$intervention %in% c("irs-llin", "irs-llin-pbo") &
      table$netUse == intervention_settings$netUse &
      table$irsUse == intervention_settings$irsUse
    )
  }
  table <- table[rows, c("intervention", "casesAverted", "casesAvertedErrorMinus", "casesAvertedErrorPlus")]
  colnames(table) <- c("intervention", "cases_averted", "cases_averted_error_minus", "cases_averted_error_plus")
  table
}

get_cost_data <- function(baseline_settings, intervention_settings, interventions) {
  costs <- lapply(interventions, function(intervention) {
    cost <- get_cost(baseline_settings, intervention_settings, intervention)
    list(intervention = intervention, cost = cost)
  })
  do.call(rbind.data.frame, costs)
}

strategise <- function(options, db) {
  data <- lapply(options$zones, function(zone) {
    data <- get_intervention_data(zone$baselineSettings,
                                  zone$interventionSettings, db)
    cost <- get_cost_data(zone$baselineSettings, zone$interventionSettings,
                      unique(data$intervention))
    data <- merge(data, cost, by = "intervention", sort = FALSE)
    data$zone <- zone$name
    data
  })
  data <- do.call(rbind, data)
  # The optimiser doesn't preserve extraneous columns so we save them here
  # and merge them back into its output
  errors <- data[c("zone", "intervention", "cases_averted_error_minus", "cases_averted_error_plus")]
  lapply(c(1, 0.95, 0.9, 0.85, 0.8), function(cost_threshold) {
    budget <- options$budget * cost_threshold
    res <- do_optimise(data, budget)
    res <- merge(res, errors, by = c("zone", "intervention"), sort = FALSE)
    names(res)[names(res) == "cases_averted"] <- "casesAverted"
    names(res)[names(res) == "cases_averted_error_minus"] <- "casesAvertedErrorMinus"
    names(res)[names(res) == "cases_averted_error_plus"] <- "casesAvertedErrorPlus"
    list(
      costThreshold = cost_threshold,
      interventions = res[c("zone", "intervention", "cost", "casesAverted", "casesAvertedErrorMinus", "casesAvertedErrorPlus")]
    )
  })
}
