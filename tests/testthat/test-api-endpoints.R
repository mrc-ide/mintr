context("api: endpoints")

test_that("table impact config", {
  res <- target_table_impact_config()
  expect_is(res, "json")

  endpoint <- endpoint_table_impact_config()
  res_endpoint <- endpoint$run()
  expect_equal(res_endpoint$status_code, 200)
  expect_equal(res_endpoint$content_type, "application/json")
  expect_equal(res_endpoint$data, res)

  res_api <- api_build()$request("GET", "/table/impact/config")
  expect_equal(res_api$status, 200)
  expect_equal(res_api$body, res_endpoint$body)
})
