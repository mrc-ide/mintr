api_run <- function(port) {
  api_build()$run("0.0.0.0", port) # nocov
}


api_build <- function() {
  pr <- pkgapi::pkgapi$new()
  pr$handle(endpoint_baseline_options())
  pr$handle(endpoint_graph_prevalence_data())
  pr$handle(endpoint_graph_prevalence_config())
  pr$handle(endpoint_graph_prevalence_data())
  pr$handle(endpoint_table_impact_config())
  pr$handle(endpoint_table_impact_data())
  pr$handle(endpoint_graph_cost_data())
  #pr$handle(endpoint_graph_cost_cases_averted_config())
  pr$handle(endpoint_intervention_options())
  pr
}


## Every endpoint comes as a pair of functions:
##
## * an endpoint generator function, which returns a pkgapi_endpoint
##   object
## * a target function, which carries out the request
##
## We hope that we'll be able to use a roxygen extension to eventually
## automate the creation of the endpoint functions from some
## annotations around the target functions, but that's a way off
## still.

## At present these endpoints just return some sample responses
## directly from from inst/json - however, it's possible that the
## /config endpoints will stay like this as it's not terrible to edit.
endpoint_baseline_options <- function() {
  pkgapi::pkgapi_endpoint$new(
    "GET", "/baseline/options", target_baseline_options,
    returning = pkgapi::pkgapi_returning_json("DynamicFormOptions.schema",
                                              schema_root()))
}


target_baseline_options <- function() {
  read_json(mintr_path("json/baseline_options.json"))
}


endpoint_graph_prevalence_config <- function() {
  pkgapi::pkgapi_endpoint$new(
    "GET", "/graph/prevalence/config", target_graph_prevalence_config,
    returning = pkgapi::pkgapi_returning_json("Graph.schema",
                                              schema_root()))
}


target_graph_prevalence_config <- function() {
  read_json(mintr_path("json/graph_prevalence_config.json"))
}


endpoint_graph_prevalence_data <- function() {
  root <- schema_root()
  pkgapi::pkgapi_endpoint$new(
    "POST", "/graph/prevalence/data", target_graph_prevalence_data,
    pkgapi::pkgapi_input_body_json("options", "DataOptions.schema", root),
    returning = pkgapi::pkgapi_returning_json("Data.schema", root))
}


target_graph_prevalence_data <- function(options) {
  force(options)
  read_json(mintr_path("json/graph_prevalence_data.json"))
}


endpoint_table_impact_config <- function() {
  pkgapi::pkgapi_endpoint$new(
    "GET", "/table/impact/config", target_table_impact_config,
    returning = pkgapi::pkgapi_returning_json("TableDefinition.schema",
                                              schema_root()))
}


target_table_impact_config <- function() {
  read_json(mintr_path("json/table_impact_config.json"))
}


endpoint_table_impact_data <- function() {
  root <- schema_root()
  pkgapi::pkgapi_endpoint$new(
    "POST", "/table/impact/data", target_table_impact_data,
    pkgapi::pkgapi_input_body_json("options", "DataOptions.schema", root),
    returning = pkgapi::pkgapi_returning_json("Data.schema", root))
}


target_table_impact_data <- function(options) {
  force(options)
  read_json(mintr_path("json/table_impact_data.json"))
}


endpoint_graph_cost_data <- function() {
  root <- schema_root()
  pkgapi::pkgapi_endpoint$new(
    "POST", "graph/cost/data", target_graph_cost_data,
    pkgapi::pkgapi_input_body_json("options", "DataOptions.schema", root),
    returning = pkgapi::pkgapi_returning_json("Data.schema", root)
  )
}


target_graph_cost_data <- function(options) {
  force(options)
  read_json(mintr_path("graph_cost_effectiveness_data.json"))
}


endpoint_intervention_options <- function() {
  root <- schema_root()
  pkgapi::pkgapi_endpoint$new(
    "GET", "/intervention/options", target_intervention_options,
    returning = pkgapi::pkgapi_returning_json("DynamicFormOptions.schema", root))
}


target_intervention_options <- function() {
  read_json(mintr_path("json/intervention_options.json"))
}
