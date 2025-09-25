#' @import tidyr
#' @import dplyr
do_optimise <- function(data, budget) {
  # rmpk requires an equal number of scenarios for each region, so we add missing
  # combinations ensuring that they are less attractive than no intervention
  data <- complete(data, region, intervention, fill = list(cost = max(data$cost), casesAverted = 0))
  region <- intervention <- cost <- casesAverted <- i <- j <- NULL # used by dplyr
  cost_df <- distinct(data, region, intervention, cost) %>%
    group_by(intervention) %>%
    mutate(j = cur_group_id()) %>%
    group_by(region) %>%
    mutate(i = cur_group_id()) %>%
    ungroup()
  cases_av_df <- distinct(data, region, intervention, casesAverted) %>%
    group_by(intervention) %>%
    mutate(j = cur_group_id()) %>%
    group_by(region) %>%
    mutate(i = cur_group_id()) %>%
    ungroup()
  cost <- function(region, intervention) {
    filter(cost_df, i == !!region, j == !!intervention)$cost
  }
  cases_av <- function(region, intervention) {
    filter(cases_av_df, i == !!region, j == !!intervention)$casesAverted
  }
  n_regions <- n_distinct(data$region)
  n_interventions <- n_distinct(data$intervention)

  ##' @import ROI.plugin.glpk
  optimise <- function(budget) {
    value <- NULL # used by dplyr
    model <- rmpk::optimization_model(rmpk::ROI_optimizer("glpk"))
    y <- model$add_variable("y", i = 1:n_regions, j = 1:n_interventions, type = "integer", lb = 0, ub = 1)
    model$set_objective(rmpk::sum_expr(y[i, j] * cases_av(i, j), i = 1:n_regions, j = 1:n_interventions), sense = "max")
    # rmpk currently fails if all scenarios have zero cost. work around this by
    # only constraining costs if some non-zero cost scenarios are provided.
    if (n_interventions > 1) {
      model$add_constraint(rmpk::sum_expr(y[i, j] * cost(i, j), i = 1:n_regions, j = 1:n_interventions) <= budget)
    }
    model$add_constraint(rmpk::sum_expr(y[i, j], j = 1:n_interventions) == 1, i = 1:n_regions)
    model$optimize()
    model$get_variable_value(y[i, j]) %>%
      filter(value == 1) %>%
      left_join(cost_df, c("i", "j")) %>%
      left_join(select(cases_av_df, casesAverted, i, j), by = c("i", "j"))
  }

  optimise(budget) %>%
    select(region, intervention, cost, casesAverted) %>%
    arrange(region)
}
