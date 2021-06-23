#' @import dplyr
#' @import tidyr
do_optimise <- function(data, budget) {
  zone <- intervention <- cost <- cases_averted <- i <- j <- NULL # used by dplyr

  # Due to a limitation in the optimiser it currently requires at least two
  # scenarios with non-zero cases_averted - this workaround therefore adds two
  # dummy scenarios, with budget-exceeding costs to ensure they are not selected
  data <- bind_rows(data,
      distinct(data, zone) %>%
        crossing(data.frame(
          intervention = c("dummy_1", "dummy_2"),
          cost = rep(budget * 10 + 1, 2),
          cases_averted = rep(1, 2)
        ))
  )

  cost_df <- distinct(data, zone, intervention, cost) %>%
    group_by(intervention) %>%
    mutate(j = cur_group_id()) %>%
    group_by(zone) %>%
    mutate(i = cur_group_id()) %>%
    ungroup()
  cases_av_df <- distinct(data, zone, intervention, cases_averted) %>%
    group_by(intervention) %>%
    mutate(j = cur_group_id()) %>%
    group_by(zone) %>%
    mutate(i = cur_group_id()) %>%
    ungroup()
  cost <- function(zone, intervention) {
    filter(cost_df, i == !!zone, j == !!intervention)$cost
  }
  cases_av <- function(zone, intervention) {
    filter(cases_av_df, i == !!zone, j == !!intervention)$cases_averted
  }
  n_zones <- n_distinct(data$zone)
  n_interventions <- n_distinct(data$intervention)

  ##' @import ROI.plugin.glpk
  optimise <- function(budget) {
    value <- NULL # used by dplyr
    model <- rmpk::optimization_model(rmpk::ROI_optimizer("glpk"))
    y <- model$add_variable("y", i = 1:n_zones, j = 1:n_interventions, type = "integer", lb = 0, ub = 1)
    model$set_objective(rmpk::sum_expr(y[i, j] * cases_av(i, j), i = 1:n_zones, j = 1:n_interventions), sense = "max")
    model$add_constraint(rmpk::sum_expr(y[i, j] * cost(i, j), i = 1:n_zones, j = 1:n_interventions) <= budget)
    model$add_constraint(rmpk::sum_expr(y[i, j], j = 1:n_interventions) == 1, i = 1:n_zones)
    model$optimize()
    model$get_variable_value(y[i, j]) %>%
      filter(value == 1) %>%
      left_join(cost_df, c("i", "j")) %>%
      left_join(select(cases_av_df, cases_averted, i, j), by = c("i", "j"))
  }

  optimise(budget) %>%
    select(zone, intervention, cost, cases_averted) %>%
    arrange(zone)
}
