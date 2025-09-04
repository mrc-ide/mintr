api_run <- function(port, db, emulator_root) {
  api_build(db, emulator_root)$run("0.0.0.0", port) # nocov
}


api_build <- function(db, emulator_root=NULL) {
  pr <- porcelain::porcelain$new(validate=TRUE)
  pr$handle(endpoint_root())
  pr$handle(endpoint_options())
  pr$handle(endpoint_baseline_options())
  pr$handle(endpoint_graph_prevalence_data(db))
  pr$handle(endpoint_graph_prevalence_config())
  pr$handle(endpoint_table_impact_config())
  pr$handle(endpoint_table_cost_config())
  pr$handle(endpoint_table_data(db))
  pr$handle(endpoint_graph_cost_per_case_config())
  pr$handle(endpoint_graph_cost_cases_averted_config())
  pr$handle(endpoint_intervention_options())
  pr$handle(endpoint_graph_cases_averted_config())
  pr$handle(endpoint_impact_intepretation(db))
  pr$handle(endpoint_cost_intepretation(db))
  pr$handle(endpoint_strategise(db))
  pr$handle(endpoint_version())
  pr$handle(endpoint_emulator_run())
  if (!is.null(emulator_root)) {
    pr$handle(endpoint_emulator_config(emulator_root))
    pr$handle(endpoint_emulator_model(emulator_root))
  }
  pr
}

# TODO: remove all old endpoints later

## Every endpoint comes as a pair of functions:
##
## * an endpoint generator function, which returns a porcelain_endpoint
##   object
## * a target function, which carries out the request
##
## We hope that we'll be able to use a roxygen extension to eventually
## automate the creation of the endpoint functions from some
## annotations around the target functions, but that's a way off
## still.

endpoint_root <- function() {
  porcelain::porcelain_endpoint$new("GET",
                                    "/",
                                    target_root,
                                    returning = porcelain::porcelain_returning_json())
}


target_root <- function() {
  jsonlite::unbox("Welcome to mintr")
}

endpoint_version <- function() {
  porcelain::porcelain_endpoint$new("GET",
                                    "/version",
                                    target_version,
                                    returning = porcelain::porcelain_returning_json("Version"))
}


target_version <- function() {
  jsonlite::toJSON(cache$versions, auto_unbox= TRUE)
}


## At present these endpoints just return some sample responses
## directly from from inst/json - however, it's possible that the
## /config endpoints will stay like this as it's not terrible to edit.
endpoint_options <- function() {
  porcelain::porcelain_endpoint$new(
    "GET", "/options", target_options,
    returning = porcelain::porcelain_returning_json("FormOptions")
  )
}

target_options <- function() {
  read_json(mintr_path("json/options.json"))
}

# TODO: delete these later
endpoint_baseline_options <- function() {
  porcelain::porcelain_endpoint$new(
    "GET", "/baseline/options", target_baseline_options,
    returning = porcelain::porcelain_returning_json("DynamicFormOptions"))
}


target_baseline_options <- function() {
  read_json(mintr_path("json/baseline_options.json"))
}


endpoint_graph_prevalence_config <- function() {
  porcelain::porcelain_endpoint$new(
    "GET", "/graph/prevalence/config", target_graph_prevalence_config,
    returning = porcelain::porcelain_returning_json("Graph"))
}


target_graph_prevalence_config <- function() {
  read_json(mintr_path("json/graph_prevalence_config.json"))
}


endpoint_graph_prevalence_data <- function(db) {
  porcelain::porcelain_endpoint$new(
    "POST", "/graph/prevalence/data",
    target_graph_prevalence_data(db),
    porcelain::porcelain_input_body_json("options", "DataOptions"),
    returning = porcelain::porcelain_returning_json("Data"))
}


target_graph_prevalence_data <- function(db) {
  force(db)
  function(options) {
    db$get_prevalence(jsonlite::fromJSON(options))
  }
}


endpoint_table_impact_config <- function() {
  porcelain::porcelain_endpoint$new(
    "GET", "/table/impact/config", target_table_impact_config,
    returning = porcelain::porcelain_returning_json("TableDefinition"))
}


target_table_impact_config <- function() {
  read_json(mintr_path("json/table_impact_config.json"))
}


endpoint_table_cost_config <- function() {
  porcelain::porcelain_endpoint$new(
    "GET", "/table/cost/config", target_table_cost_config,
    returning = porcelain::porcelain_returning_json("TableDefinition"))
}


target_table_cost_config <- function() {
  read_json(mintr_path("json/table_cost_config.json"))
}


endpoint_table_data <- function(db) {
  porcelain::porcelain_endpoint$new(
    "POST", "/table/data", target_table_data(db),
    porcelain::porcelain_input_body_json("options", "DataOptions"),
    returning = porcelain::porcelain_returning_json("Data"))
}


target_table_data <- function(db) {
  force(db)
  function(options) {
    db$get_table(jsonlite::fromJSON(options))
  }
}


endpoint_graph_cost_cases_averted_config <- function() {
  porcelain::porcelain_endpoint$new(
    "GET", "/graph/cost/cases-averted/config", target_graph_cost_cases_averted_config,
    returning = porcelain::porcelain_returning_json("Graph"))
}


target_graph_cost_cases_averted_config <- function() {
  read_json(mintr_path("json/graph_cost_cases_averted_config.json"))
}


endpoint_graph_cost_per_case_config <- function() {
  porcelain::porcelain_endpoint$new(
    "GET", "/graph/cost/per-case/config", target_graph_cost_per_case_config,
    returning = porcelain::porcelain_returning_json("Graph"))
}


target_graph_cost_per_case_config <- function() {
  read_json(mintr_path("json/graph_cost_per_case_config.json"))
}


endpoint_intervention_options <- function() {
  porcelain::porcelain_endpoint$new(
    "GET", "/intervention/options", target_intervention_options,
    returning = porcelain::porcelain_returning_json("DynamicFormOptions"))
}


target_intervention_options <- function() {
  read_json(mintr_path("json/intervention_options.json"))
}


endpoint_graph_cases_averted_config <- function() {
  porcelain::porcelain_endpoint$new(
    "GET", "/graph/impact/cases-averted/config", target_graph_cases_averted_config,
    returning = porcelain::porcelain_returning_json("Graph"))
}


target_graph_cases_averted_config <- function() {
  read_json(mintr_path("json/graph_cases_averted_config.json"))
}


endpoint_impact_intepretation <- function(db) {
  porcelain::porcelain_endpoint$new(
    "GET", "/docs/impact", target_impact_interpretation(db),
    returning = porcelain::porcelain_returning_json("Docs"))
}


target_impact_interpretation <- function(db) {
  force(db)
  function() {
    db$get_impact_docs()
  }
}


endpoint_cost_intepretation <- function(db) {
  porcelain::porcelain_endpoint$new(
    "GET", "/docs/cost", target_cost_interpretation(db),
    returning = porcelain::porcelain_returning_json("Docs"))
}

target_cost_interpretation <- function(db) {
  force(db)
  function() {
    db$get_cost_docs()
  }
}

endpoint_strategise <- function(db) {
  porcelain::porcelain_endpoint$new(
    "POST", "/strategise",
    target_strategise(db),
    porcelain::porcelain_input_body_json("json", "StrategiseOptions"),
    returning = porcelain::porcelain_returning_json("Strategise"))
}

target_strategise <- function(db) {
  force(db)
  function(json) {
    jsonlite::toJSON(
      strategise(jsonlite::fromJSON(json, simplifyVector=FALSE), db),
      auto_unbox=TRUE
    )
  }
}

endpoint_emulator_run <- function() {
  porcelain::porcelain_endpoint$new(
    "POST", "/emulator/run", target_emulator_run,
    porcelain::porcelain_input_body_json("options", "EmulatorOptions"),
    returning = porcelain::porcelain_returning_json("EmulatorResults"))
}

target_emulator_run <- function(options) {
    run_emulator(jsonlite::fromJSON(options))  
}

# TODO: remove all old emulator references
endpoint_emulator_config <- function(emulator_root) {
  porcelain::porcelain_endpoint$new(
    "GET", "/emulator/config", target_emulator_config(emulator_root),
    returning = porcelain::porcelain_returning_json("EmulatorOptions"))
}

target_emulator_config <- function(emulator_root) {
  function() {
    read_json(file.path(emulator_root, "config.json"))
  }
}

endpoint_emulator_model <- function(emulator_root) {
  porcelain::porcelain_endpoint$new(
    "GET", "/emulator/model/<filename>", target_emulator_model(emulator_root),
    returning = porcelain::porcelain_returning_binary())
}

target_emulator_model <- function(emulator_root) {
  function(filename) {
    path <- file.path(emulator_root, "models", filename)
    readBin(path, raw(), n = file.size(path))
  }
}
