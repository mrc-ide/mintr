strategise <- function(options, db) {
  cost <- function(baseline_settings, intervention_settings, intervention) {
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

  cases_averted <- function(baseline_settings, intervention_settings, intervention) {
    table <- db$get_table(baseline_settings)
    switch(
      intervention,
      "none" = subset(
        table,
        intervention == "none"
      ),
      "llin" = subset(
        table,
        intervention == "llin"
          & netUse == intervention_settings$netUse
          & irsUse == "n/a"
      ),
      "llin-pbo" =
        subset(
          table,
          intervention == "llin-pbo"
            & netUse == intervention_settings$netUse
            & irsUse == "n/a"
        ),
      "irs" = subset(
        table,
        intervention == "irs"
          & netUse == "n/a"
          & irsUse == intervention_settings$irsUse
      ),
      "irs-llin" = subset(
        table,
        intervention == "irs-llin"
          & netUse == intervention_settings$netUse
          & irsUse == intervention_settings$irsUse
      ),
      "irs-llin-pbo" = subset(
        table,
        intervention == "irs-llin-pbo"
          & netUse == intervention_settings$netUse
          & irsUse == intervention_settings$irsUse
      )
    )$casesAverted
  }

  data <- data.frame(
    zone=character(),
    intervention=character(),
    cost=numeric(),
    cases_averted=numeric()
  )
  for (zone in options$zones) {
    interventions <- c("none")
    if (zone$interventionSettings$netUse != "0") {
      interventions <- append(interventions, c("llin", "llin-pbo"))
    }
    if (zone$interventionSettings$irsUse != "0") {
      interventions <- append(interventions, c("irs"))
    }
    if (zone$interventionSettings$netUse != "0"
      && zone$interventionSettings$irsUse != "0") {
      interventions <- append(interventions, c("irs-llin", "irs-llin-pbo"))
    }
    for (intervention in interventions) {
      data <- rbind(data, data.frame(
        zone = zone$name,
        intervention = intervention,
        cost = cost(
          zone$baselineSettings,
          zone$interventionSettings,
          intervention
        ),
        cases_averted = cases_averted(
          zone$baselineSettings,
          zone$interventionSettings,
          intervention
        )
      ))
    }
  }
  Map(
    function(cost_threshold) {
      budget <- options$budget * cost_threshold
      res <- do_optimise(data, budget)
      list(
        costThreshold = cost_threshold,
        strategy = list(
          cost = sum(res$cost),
          casesAverted = sum(res$cases_averted),
          interventions = res[c("zone", "intervention")]
        )
      )
    },
    c(1, 0.95, 0.9, 0.85, 0.8)
  )
}
