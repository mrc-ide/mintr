context("main")

test_that("cli can parse port", {
  expect_equal(main_args(character()), list(port = 8888))
  expect_equal(main_args("--port=1234"), list(port = 1234))
})


test_that("cli can call api", {
  skip_if_not_installed("mockery")
  mock_api <- mockery::mock()
  mockery::stub(main, "api_run", mock_api)
  main(c("--port=1234"))

  mockery::expect_called(mock_api, 1)
  expect_equal(mockery::mock_args(mock_api), list(list(1234L)))
})


test_that("Can write script", {
  path <- tempfile()
  res <- write_script(path)
  expect_equal(basename(res), "mintr")
  expect_equal(file.info(res)$mode, as.octmode("755"))
})
