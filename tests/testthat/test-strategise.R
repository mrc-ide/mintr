
library(jsonlite)
library(dplyr)
library(purrr)

test_that("add_no_intervention adds no_intervention row correctly", {
  # Test with sample interventions data
  interventions_df <- data.frame(
    intervention = c("lsm_only", "irs_only"),
    cost = c(1000, 1500),
    casesAverted = c(50, 70)
  )
  
  result <- add_no_intervention(interventions_df)
  
  expect_equal(nrow(result), 3)
  expect_true("no_intervention" %in% result$intervention)
  
  no_intervention_row <- result |> filter(intervention == "no_intervention")
  expect_equal(no_intervention_row$cost, 0)
  expect_equal(no_intervention_row$casesAverted, 0)
})

test_that("add_no_intervention works with empty interventions", {
  empty_df <- data.frame(
  intervention = character(0),
  cost = numeric(0),
  casesAverted = numeric(0)
  )
  
  result <- add_no_intervention(empty_df)
  
  expect_equal(nrow(result), 1)
  expect_equal(result$intervention, "no_intervention")
  expect_equal(result$cost, 0)
  expect_equal(result$casesAverted, 0)
})

test_that("unnest_region_data processes regions correctly", {  
  # Test with subset of regions
  regions_subset <- create_strategise_test_data()$regions  
  result <- unnest_region_data(regions_subset)

  expect_equal(sum(result$region == "Region A"), 2) # 1 original + 1 no_intervention
  expect_equal(sum(result$region == "Region B"), 4) # 3 original + 1 no_intervention
  expect_equal(sum(result$region == "Region C"), 5) # 4 original + 1 no_intervention
})

test_that("unnest_region_data handles single region", {
  single_region <- create_strategise_test_data()$regions[1, , drop = FALSE]
  
  result <- unnest_region_data(single_region)
  
  expect_true(nrow(result) > 0)
  expect_true("no_intervention" %in% result$intervention)
  expect_equal(sum(result$intervention == "no_intervention"), 1)
})

test_that("strategise returns correct structure", {
  test_data <- create_strategise_test_data()
  result <- strategise(test_data)

    # Check that result is a list with 200 elements
    expect_equal(length(result), 200)
    
    # Check structure of each threshold result
    for (i in seq_along(result)) {
      expect_true("costThreshold" %in% names(result[[i]]))
      expect_true("interventions" %in% names(result[[i]]))
      expect_equal(nrow(result[[i]]$interventions), 3) # 1 for each region
    }
    
    # Check that cost thresholds are correct
    expected_thresholds  <- seq(from = test_data$minCost, to = test_data$maxCost, length.out = 200) |> round()
    actual_thresholds <- sapply(result, function(x) x$costThreshold)
    expect_equal(actual_thresholds, expected_thresholds)
})



