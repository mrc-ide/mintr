get_data <- function() {
  tibble::tribble(
    ~zone, ~intervention,                  ~cost,            ~cases_averted,
    "A",   "No intervention",              0,                0,
    "A",   "IRS only",                     2107590,          357880.968553733,
    "A",   "Pyrethroid-only ITN only",         351510.8855,      13119.7945853333,
    "A",   "Pyrethroid-PBO ITN only",     410096.033083333, 45938.0737261667,
    "A",   "Pyrethroid-only ITN with IRS",     2459100.8855,     354230.41074385,
    "A",   "Pyrethroid-PBO ITN with IRS", 2517686.03308333, 356708.6871857,
    "B",   "No intervention",              0,                0,
    "B",   "IRS only",                     210750,           22701.5340775,
    "B",   "Pyrethroid-only ITN only",         35149.5875,       8481.55158091667,
    "B",   "Pyrethroid-PBO ITN only",     41007.8520833333, 11145.2462262917,
    "B",   "Pyrethroid-only ITN with IRS",     245899.5875,      22856.8245007917,
    "B",   "Pyrethroid-PBO ITN with IRS", 251757.852083333, 23705.0551284583
  )
}

test_that("optimise gives the expected results", {
  data <- get_data()
  budget <- sum(data$cost) / 4

  res_full_cost <- do_optimise(data, budget)
  expect_true(sum(res_full_cost$cost) <= budget)
  expect_equal(res_full_cost, as.data.frame(slice(data, 2, 10)))

  res_reduced_cost <- do_optimise(data, budget * 0.8)
  expect_true(sum(res_reduced_cost$cost) <= budget)
  expect_equal(res_reduced_cost, as.data.frame(slice(data, 4, 12)))

  expect_lte(sum(res_reduced_cost$cost), sum(res_full_cost$cost))
  expect_lte(sum(res_reduced_cost$cases_averted), sum(res_full_cost$cases_averted))
})

test_that("optimise gives the expected results with minimal cost", {
  data <- get_data()
  budget <- min(data$cost) / 4

  res <- do_optimise(data, budget)
  expect_equal(res, as.data.frame(slice(data, 1, 7)))
})

test_that("optimise gives the expected results with no interventions", {
  data <- get_data()
  data <- as.data.frame(slice(data, 1))
  budget <- sum(data$cost) / 4

  res <- do_optimise(data, budget)
  expect_equal(res, as.data.frame(slice(data, 1)))
})

test_that("optimise gives the expected results with a single intervention", {
  data <- get_data()
  data <- as.data.frame(slice(data, 1, 2))
  budget <- max(data$cost)

  res <- do_optimise(data, budget)
  expect_equal(res, as.data.frame(slice(data, 2)))
})
