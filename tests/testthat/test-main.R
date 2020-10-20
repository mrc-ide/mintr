context("main")

test_that("cli can parse port", {
  expect_equal(main_args(character()), list(port = 8888, data = "data"))
  expect_equal(main_args("--port=1234"), list(port = 1234, data = "data"))
})


test_that("cli can call api", {
  skip_if_not_installed("mockery")
  mock_api <- mockery::mock()
  mockery::stub(main, "api_run", mock_api)
  main(c("--port=1234", "--data=data"))

  mockery::expect_called(mock_api, 1)
  expect_equal(mockery::mock_args(mock_api)[[1]][[1]], 1234L)
  expect_s3_class(mockery::mock_args(mock_api)[[1]][[2]], "mint_db")
})


test_that("Can write script", {
  path <- tempfile()
  res <- write_script(path)
  expect_equal(basename(res), "mintr")
  expect_equal(file.info(res)$mode, as.octmode("755"))
})
