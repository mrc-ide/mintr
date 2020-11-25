context("util")

test_that("null-or-value works", {
  expect_equal(1 %||% NULL, 1)
  expect_equal(1 %||% 2, 1)
  expect_equal(NULL %||% NULL, NULL)
  expect_equal(NULL %||% 2, 2)
})


test_that("assert_setequal gives useful messages", {
  x <- rep(c("a", "b", "c"), each = 2)
  expect_silent(assert_setequal(x, c("a", "b", "c")))
  expect_error(assert_setequal(x, c("a", "b")),
               "Invalid value for 'x':.*- Unexpected: c")
  expect_error(assert_setequal(x, c("a")),
               "Invalid value for 'x':.*- Unexpected: b, c")
  expect_error(
    assert_setequal(x, c("a", "d")),
    "Invalid value for 'x':.*- Unexpected: b, c.*- Missing: d")
  expect_error(assert_setequal(x, c("a", "b", "c", "d")),
               "Invalid value for 'x':.*- Missing: d")
})


test_that("downloader does not create file on failed download", {
  dest <- tempfile()
  expect_error(
    suppressWarnings(download_file("https://httpbin.org/status/500", dest,
                                   quiet = TRUE)))
  expect_false(file.exists(dest))
})


test_that("downloader can download a file", {
  first <- "Zmlyc3QK"
  second <- "c2Vjb25kCg=="
  dest <- tempfile()
  download_file(paste0("https://httpbin.org/base64/", first), dest,
                quiet = TRUE)
  expect_equal(readLines(dest), "first")
  download_file(paste0("https://httpbin.org/base64/", second), dest,
                quiet = TRUE)
  expect_equal(readLines(dest), "second")
})

