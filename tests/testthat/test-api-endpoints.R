context("api: endpoints")


test_that("root endpoint", {
  res <- target_root()
  expect_equal(res, jsonlite::unbox("Welcome to mintr"))

  endpoint <- endpoint_root()
  res_endpoint <- endpoint$run()
  expect_equal(res_endpoint$status_code, 200)
  expect_equal(res_endpoint$content_type, "application/json")
  expect_equal(res_endpoint$data, res)

  api <- api_build(mintr_test_db())
  res_api <- api$request("GET", "/")
  expect_equal(res_api$status, 200)
  expect_equal(res_api$body, res_endpoint$body)
})


test_that("baseline options have valid defaults", {
  res <- target_baseline_options()
  dat <- jsonlite::fromJSON(res, FALSE)

  for (section in dat$controlSections) {
    for (group in section$controlGroups) {
      for (control in group$controls) {
        if (control$type == "select") {
          valid <- vcapply(control$options, "[[", "id")
          expect_true(control$value %in% valid)
        }
      }
    }
  }
})


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

  api <- api_build(mintr_test_db())
  res_api <- api$request("GET", "/baseline/options")
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

  api <- api_build(mintr_test_db())
  res_api <- api$request("GET", "/graph/prevalence/config")
  expect_equal(res_api$status, 200)
  expect_equal(res_api$body, res_endpoint$body)
})


test_that("graph prevalence data", {
  options <- list(population = 1000,
                  metabolic = "yes",
                  seasonalityOfTransmission = "seasonal",
                  currentPrevalence = "30%",
                  bitingIndoors = "high",
                  bitingPeople = "high",
                  levelOfResistance = "80%",
                  itnUsage = "20%",
                  sprayInput = "0%")
  json <- jsonlite::toJSON(lapply(options, jsonlite::unbox))

  db <- mintr_test_db()
  res <- target_graph_prevalence_data(db)(json)
  expect_equal(res, db$get_prevalence(options))

  endpoint <- endpoint_graph_prevalence_data(db)
  res_endpoint <- endpoint$run(json)
  expect_equal(res_endpoint$status_code, 200)
  expect_equal(res_endpoint$content_type, "application/json")
  expect_equal(res_endpoint$data, res)

  api <- api_build(db)
  res_api <- api$request("POST", "/graph/prevalence/data", body = json)

  expect_equal(res_api$status, 200)
  expect_equal(res_api$body, res_endpoint$body)
})


test_that("table cost config", {
  res <- target_table_cost_config()
  expect_is(res, "json")
  expect_identical(res,
                   read_json(mintr_path("json/table_cost_config.json")))

  endpoint <- endpoint_table_cost_config()
  res_endpoint <- endpoint$run()
  expect_equal(res_endpoint$status_code, 200)
  expect_equal(res_endpoint$content_type, "application/json")
  expect_equal(res_endpoint$data, res)

  api <- api_build(mintr_test_db())
  res_api <- api$request("GET", "/table/cost/config")
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

  api <- api_build(mintr_test_db())
  res_api <- api$request("GET", "/table/impact/config")
  expect_equal(res_api$status, 200)
  expect_equal(res_api$body, res_endpoint$body)
})


test_that("table data", {
  options <- list(population = 1000,
                  metabolic = "yes",
                  seasonalityOfTransmission = "seasonal",
                  currentPrevalence = "30%",
                  bitingIndoors = "high",
                  bitingPeople = "high",
                  levelOfResistance = "80%",
                  itnUsage = "20%",
                  sprayInput = "0%")
  json <- jsonlite::toJSON(lapply(options, jsonlite::unbox))

  db <- mintr_test_db()
  res <- target_table_data(db)(json)
  expect_equal(res, db$get_table(options))

  endpoint <- endpoint_table_data(db)
  res_endpoint <- endpoint$run(json)
  expect_equal(res_endpoint$status_code, 200)
  expect_equal(res_endpoint$content_type, "application/json")
  expect_equal(res_endpoint$data, res)

  api <- api_build(mintr_test_db())
  res_api <- api$request("POST", "/table/data", body = json)
  expect_equal(res_api$status, 200)
  expect_equal(res_api$body, res_endpoint$body)
})

test_that("graph cost cases averted config", {
  res <- target_graph_cost_cases_averted_config()
  expect_is(res, "json")
  expect_identical(res,
                   read_json(mintr_path("json/graph_cost_cases_averted_config.json")))

  endpoint <- endpoint_graph_cost_cases_averted_config()
  res_endpoint <- endpoint$run()
  expect_equal(res_endpoint$status_code, 200)
  expect_equal(res_endpoint$content_type, "application/json")
  expect_equal(res_endpoint$data, res)

  api <- api_build(mintr_test_db())
  res_api <- api$request("GET", "/graph/cost/cases-averted/config")
  expect_equal(res_api$status, 200)
  expect_equal(res_api$body, res_endpoint$body)
})


test_that("graph cost per case config", {
  res <- target_graph_cost_per_case_config()
  expect_is(res, "json")
  expect_identical(res,
                   read_json(mintr_path("json/graph_cost_per_case_config.json")))

  endpoint <- endpoint_graph_cost_per_case_config()
  res_endpoint <- endpoint$run()
  expect_equal(res_endpoint$status_code, 200)
  expect_equal(res_endpoint$content_type, "application/json")
  expect_equal(res_endpoint$data, res)

  api <- api_build(mintr_test_db())
  res_api <- api$request("GET", "/graph/cost/per-case/config")
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

  api <- api_build(mintr_test_db())
  res_api <- api$request("GET", "/intervention/options")
  expect_equal(res_api$status, 200)
  expect_equal(res_api$body, res_endpoint$body)
})


test_that("graph cases averted config", {
  res <- target_graph_cases_averted_config()
  expect_is(res, "json")
  expect_identical(res,
                   read_json(mintr_path("json/graph_cases_averted_config.json")))

  endpoint <- endpoint_graph_cases_averted_config()
  res_endpoint <- endpoint$run()
  expect_equal(res_endpoint$status_code, 200)
  expect_equal(res_endpoint$content_type, "application/json")
  expect_equal(res_endpoint$data, res)

  api <- api_build(mintr_test_db())
  res_api <- api$request("GET", "/graph/impact/cases-averted/config")
  expect_equal(res_api$status, 200)
  expect_equal(res_api$body, res_endpoint$body)
})


test_that("impact docs", {
  db <- mintr_test_db()
  res <- target_impact_interpretation(db)()
  expect_is(res, "json")
  expect_equal(res, db$get_impact_docs())

  endpoint <- endpoint_impact_intepretation(db)
  res_endpoint <- endpoint$run()
  expect_equal(res_endpoint$status_code, 200)
  expect_equal(res_endpoint$content_type, "application/json")
  expect_equal(res_endpoint$data, res)

  api <- api_build(db)
  res_api <- api$request("GET", "/docs/impact")
  expect_equal(res_api$status, 200)
  expect_equal(res_api$body, res_endpoint$body)
})


test_that("cost docs", {
  db <- mintr_test_db()
  res <- target_cost_interpretation(db)()
  expect_is(res, "json")
  expect_equal(res, db$get_cost_docs())

  endpoint <- endpoint_cost_intepretation(db)
  res_endpoint <- endpoint$run()
  expect_equal(res_endpoint$status_code, 200)
  expect_equal(res_endpoint$content_type, "application/json")
  expect_equal(res_endpoint$data, res)

  api <- api_build(db)
  res_api <- api$request("GET", "/docs/cost")
  expect_equal(res_api$status, 200)
  expect_equal(res_api$body, res_endpoint$body)
})

test_that("strategise", {
  json <- jsonlite::toJSON(list(
    budget = 20000,
    zones = list(
      list(
        name = "Region A",
        baselineSettings = list(
          population = 1000,
          seasonalityOfTransmission = "seasonal",
          currentPrevalence = "30%",
          bitingIndoors = "high",
          bitingPeople = "low",
          levelOfResistance = "0%",
          metabolic = "yes",
          itnUsage = "0%",
          sprayInput = "0%"
        ),
        interventionSettings = list(
          procurePeoplePerNet = 1.8,
          procureBuffer = 7,
          priceDelivery = 2.75,
          priceNetPBO = 2.5,
          priceNetStandard = 1.5,
          priceIRSPerPerson = 5.73,
          netUse = "0.8",
          irsUse = "0.6"
        )
      )
    )
  ), auto_unbox=TRUE)

  db <- mintr_test_db()
  res <- target_strategise(db)(json)
  expect_is(res, "json")
  expect_equal(res, jsonlite::toJSON(
    list(
      list(
        costThreshold = 1,
        strategy = list(cost = 19716.3889, casesAverted = 595, interventions = list(
          list(zone = "Region A", intervention = "irs-llin"))
        )
      ),
      list(
        costThreshold = 0.95,
        strategy = list(cost = 17190, casesAverted = 570, interventions = list(
          list(zone = "Region A", intervention = "irs"))
        )
      ),
      list(
        costThreshold = 0.9,
        strategy = list(cost = 17190, casesAverted = 570, interventions = list(
          list(zone = "Region A", intervention = "irs"))
        )
      ),
      list(
        costThreshold = 0.85,
        strategy = list(cost = 3120.8333, casesAverted = 529, interventions = list(
          list(zone = "Region A", intervention = "llin-pbo"))
        )
      ),
      list(
        costThreshold = 0.8,
        strategy = list(cost = 3120.8333, casesAverted = 529, interventions = list(
          list(zone = "Region A", intervention = "llin-pbo"))
        )
      )
    ), auto_unbox=TRUE))

  endpoint <- endpoint_strategise(db)
  res_endpoint <- endpoint$run(json)
  expect_equal(res_endpoint$status_code, 200)
  expect_equal(res_endpoint$content_type, "application/json")
  expect_equal(res_endpoint$data, res)

  api <- api_build(db)
  res_api <- api$request("POST", "/strategise", body = json)
  expect_equal(res_api$status, 200)
  expect_equal(res_api$body, res_endpoint$body)
})
