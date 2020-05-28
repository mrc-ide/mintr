context("api: endpoints")


test_that("baseline_options", {
  res <- target_baseline_options()
  expect_is(res, "json")
  expect_identical(res,
                   read_json(mintr_path("json/baseline_options.json")))
  
  endpoint <- endpoint_baseline_options()
  res_endpoint <- endpoint$run()
  expect_equal(res_endpoint$status_code, 200)
  expect_equal(res_endpoint$content_type, "application/json")
  expect_equal(res_endpoint$data, res)
  
  res_api <- api_build()$request("GET", "/baseline/options")
  expect_equal(res_api$status, 200)
  expect_equal(res_api$body, res_endpoint$body)
})


test_that("graph prevalence config", {
  res <- target_graph_prevalence_config()
  expect_is(res, "json")
  expect_identical(res,
                   read_json(mintr_path("json/graph_prevalence_config.json")))

  endpoint <- endpoint_graph_prevalence_config()
  res_endpoint <- endpoint$run()
  expect_equal(res_endpoint$status_code, 200)
  expect_equal(res_endpoint$content_type, "application/json")
  expect_equal(res_endpoint$data, res)

  res_api <- api_build()$request("GET", "/graph/prevalence/config")
  expect_equal(res_api$status, 200)
  expect_equal(res_api$body, res_endpoint$body)
})


test_that("graph prevalence data", {
  options <- list("irs_future" = "80%",
                  "sprayInput" = 1,
                  "biting_indoors" = "high",
                  "population" = 1000)
  res <- target_graph_prevalence_data(options)
  expect_is(res, "json")
  expect_identical(res,
                   read_json(mintr_path("json/graph_prevalence_data.json")))

  endpoint <- endpoint_graph_prevalence_data()
  res_endpoint <- endpoint$run(options)
  expect_equal(res_endpoint$status_code, 200)
  expect_equal(res_endpoint$content_type, "application/json")
  expect_equal(res_endpoint$data, res)

  body <- jsonlite::toJSON(lapply(options, jsonlite::unbox))
  res_api <- api_build()$request("POST", "/graph/prevalence/data", body = body)
  expect_equal(res_api$status, 200)
  expect_equal(res_api$body, res_endpoint$body)
})


test_that("table impact config", {
  res <- target_table_impact_config()
  expect_is(res, "json")
  expect_identical(res,
                   read_json(mintr_path("json/table_impact_config.json")))

  endpoint <- endpoint_table_impact_config()
  res_endpoint <- endpoint$run()
  expect_equal(res_endpoint$status_code, 200)
  expect_equal(res_endpoint$content_type, "application/json")
  expect_equal(res_endpoint$data, res)

  res_api <- api_build()$request("GET", "/table/impact/config")
  expect_equal(res_api$status, 200)
  expect_equal(res_api$body, res_endpoint$body)
})


test_that("table impact data", {
  options <- list("irs_future" = "80%",
                  "sprayInput" = 1,
                  "biting_indoors" = "high",
                  "population" = 1000)
  res <- target_table_impact_data(options)
  expect_is(res, "json")
  expect_identical(res,
                   read_json(mintr_path("json/table_impact_data.json")))

  endpoint <- endpoint_table_impact_data()
  res_endpoint <- endpoint$run(options)
  expect_equal(res_endpoint$status_code, 200)
  expect_equal(res_endpoint$content_type, "application/json")
  expect_equal(res_endpoint$data, res)

  body <- jsonlite::toJSON(lapply(options, jsonlite::unbox))
  res_api <- api_build()$request("POST", "/table/impact/data", body = body)
  expect_equal(res_api$status, 200)
  expect_equal(res_api$body, res_endpoint$body)
})

test_that("graph cost cases averted data", {
  res <- target_graph_cost_cases_averted_config()
  expect_is(res, "json")
  expect_identical(res,
                   read_json(mintr_path("json/graph_cost_cases_averted_config.json")))
  
  endpoint <- endpoint_graph_cost_cases_averted_config()
  res_endpoint <- endpoint$run()
  expect_equal(res_endpoint$status_code, 200)
  expect_equal(res_endpoint$content_type, "application/json")
  expect_equal(res_endpoint$data, res)
  
  res_api <- api_build()$request("GET", "/graph/cost/cases-averted/config")
  expect_equal(res_api$status, 200)
  expect_equal(res_api$body, res_endpoint$body)
})


test_that("graph cost data", {
  options <- list("irs_future" = "80%",
                          "spray_input" = 1,
                          "biting_indoors" = "high",
                          "procure_people_per_net" = 1.8,
                          "procure_buffer" = 7)
  res <- target_graph_cost_data(options)
  expect_is(res, "json")
  expect_identical(res,
                   read_json(mintr_path("json/graph_cost_effectiveness_data.json")))
  
  endpoint <- endpoint_graph_cost_data()
  res_endpoint <- endpoint$run(options)
  expect_equal(res_endpoint$status_code, 200)
  expect_equal(res_endpoint$content_type, "application/json")
  expect_equal(res_endpoint$data, res)
  
  body <- jsonlite::toJSON(lapply(options, jsonlite::unbox))
  res_api <- api_build()$request("POST", "/graph/cost/data", body = body)
  expect_equal(res_api$status, 200)
  expect_equal(res_api$body, res_endpoint$body)
})


test_that("intervention options", {
  res <- target_intervention_options()
  expect_is(res, "json")
  expect_identical(res,
                   read_json(mintr_path("json/intervention_options.json")))

  endpoint <- endpoint_intervention_options()
  res_endpoint <- endpoint$run()
  expect_equal(res_endpoint$status_code, 200)
  expect_equal(res_endpoint$content_type, "application/json")
  expect_equal(res_endpoint$data, res)

  res_api <- api_build()$request("GET", "/intervention/options")
  expect_equal(res_api$status, 200)
  expect_equal(res_api$body, res_endpoint$body)
})
