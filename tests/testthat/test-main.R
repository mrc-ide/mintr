test_that("cli can parse args", {
  expect_equal(
    main_args(character()),
    list(port = 8888, data = "data", emulator_root=NULL))

  expect_equal(
    main_args("--port=1234"),
    list(port = 1234, data = "data", emulator_root=NULL))

  expect_equal(
    main_args("--data=/path/to/data"),
    list(port = 8888, data = "/path/to/data", emulator_root=NULL))

  expect_equal(
    main_args("--emulator=/path/to/emulator"),
    list(port = 8888, data = "data", emulator_root="/path/to/emulator"))
})


test_that("cli can call api", {
  skip_if_not_installed("mockery")
  mock_api <- mockery::mock()
  mock_docs <- list(impact = "impact", cost = "cost")
  mockery::stub(main, "api_run", mock_api)
  mockery::stub(main, "get_compiled_docs", mock_docs)
  main(c("--port=1234", "--data=data"))

  mockery::expect_called(mock_api, 1)
  expect_equal(mockery::mock_args(mock_api)[[1]][[1]], 1234L)
  db <- mockery::mock_args(mock_api)[[1]][[2]]
  expect_s3_class(db, "mintr_db")
  expect_equal(db$get_impact_docs(), mock_docs$impact)
  expect_equal(db$get_cost_docs(), mock_docs$cost)
})


test_that("Can write script", {
  path <- tempfile()
  res <- write_script(path)
  expect_equal(basename(res), "mintr")
  expect_equal(file.info(res)$mode, as.octmode("755"))
})


test_that("can compile docs", {
  res <- get_compiled_docs()
  expect_equal(names(res), c("impact", "cost"))
  expect_s3_class(res$impact, "json")
  expect_s3_class(res$cost, "json")

  expect_true(grepl("<strong>Cost Effectiveness</strong>", res$cost))
  expect_true(grepl("<strong>Impact</strong>", res$impact))

  expect_false(grepl("\n", res$cost))
  expect_false(grepl("\n", res$impact))
})
