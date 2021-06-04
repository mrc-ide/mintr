library(ROI.plugin.glpk)

get_data <- function() {
  tibble::tribble(
    ~zone, ~intervention,                  ~total_costs,     ~total_cases_averted,
    1,     "No intervention",              0,                0,
    1,     "IRS only",                     2107590,          357880.968553733,
    1,     "Pyrethroid LLIN only",         351510.8855,      13119.7945853333,
    1,     "Pyrethroid-PBO LLIN only",     410096.033083333, 45938.0737261667,
    1,     "Pyrethroid LLIN with IRS",     2459100.8855,     354230.41074385,
    1,     "Pyrethroid-PBO LLIN with IRS", 2517686.03308333, 356708.6871857,
    2,     "No intervention",              0,                0,
    2,     "IRS only",                     210750,           22701.5340775,
    2,     "Pyrethroid LLIN only",         35149.5875,       8481.55158091667,
    2,     "Pyrethroid-PBO LLIN only",     41007.8520833333, 11145.2462262917,
    2,     "Pyrethroid LLIN with IRS",     245899.5875,      22856.8245007917,
    2,     "Pyrethroid-PBO LLIN with IRS", 251757.852083333, 23705.0551284583
  )
}

test_that("optimise gives the expected results", {
  data <- get_data()
  budget <- sum(data$total_costs) / 4

  res_full_cost <- do_optimise(data, budget)
  expect_true(sum(res_full_cost$total_costs) <= budget)
  expect_equal(res_full_cost, as.data.frame(slice(data, 2, 10)))

  res_reduced_cost <- do_optimise(data, budget * 0.8)
  expect_true(sum(res_reduced_cost$total_costs) <= budget)
  expect_equal(res_reduced_cost, as.data.frame(slice(data, 4, 12)))

  expect_lte(sum(res_reduced_cost$total_costs), sum(res_full_cost$total_costs))
  expect_lte(sum(res_reduced_cost$total_cases_averted), sum(res_full_cost$total_cases_averted))
})

test_that("optimise gives the expected results with minimal cost", {
  data <- get_data()
  budget <- min(data$total_costs) / 4

  res <- do_optimise(data, budget)
  expect_equal(res, as.data.frame(slice(data, 1, 7)))
})
