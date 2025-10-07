strategise <- function(options) {
  combined_region_data <- unnest_region_data(options$regions)
  cost_thresholds <- seq(from = options$minCost, to = options$maxCost, length.out = 200) |> round()

  result <- parallel::mclapply(cost_thresholds, function(threshold) {
    interventions <- do_optimise(combined_region_data, threshold)

    list(
      costThreshold = threshold,
      interventions = interventions
    )
  }, mc.cores = ceiling(parallel::detectCores() %||% 1 / 4))

  result
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
