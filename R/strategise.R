strategise <- function(options) {
  combined_region_data <- unnest_region_data(options$regions)
  cost_thresholds <- c(1, 0.95, 0.9, 0.85, 0.8)
  
  lapply(cost_thresholds, function(threshold) {
    budget <- options$budget * threshold
    interventions <- do_optimise(combined_region_data, budget)

    list(
      costThreshold = threshold,
      interventions = interventions
    )
  })
}

unnest_region_data <- function(regions_df) {  
  regions_df |>
    # add no_intervention to each region's interventions
    dplyr::mutate(
      interventions = purrr::map(interventions, add_no_intervention)
    ) |>
    tidyr::unnest(interventions)
}

add_no_intervention <- function(interventions_df) {
  no_intervention <- data.frame(
    intervention = "no_intervention", 
    cost = 0, 
    casesAverted = 0
  )
  dplyr::bind_rows(interventions_df, no_intervention)
}
