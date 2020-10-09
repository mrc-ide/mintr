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
