strategise <- function(options) {
  combined_region_data <- unnest_region_data(options$regions)
  min_cost <- combined_region_data |> filter(cost > 0) |> summarise(min_cost = min(cost)) |> pull(min_cost)
  max_cost <- combined_region_data |> group_by(region) |> summarise(max_cost = max(cost), .groups = "drop") |> summarise(total = sum(max_cost)) |> pull()
  cost_thresholds <- seq(from = min_cost, to = max_cost, length.out = 200) |> round()
  
  result <- parallel::mclapply(cost_thresholds, function(threshold) {
    interventions <- do_optimise(combined_region_data, threshold)

    list(
      costThreshold = threshold,
      interventions = interventions
    )
  }, mc.cores = ceiling(parallel::detectCores() / 4))

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
