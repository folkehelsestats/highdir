# tests/testthat/test-rounding-helpers.R

test_that("round_column() - happy path rounds numeric column and returns data.frame", {
  df <- data.frame(a = c(1.234, 2.345, 3.456), b = 1:3)
  out <- round_column(df, "a", 1)

  expect_s3_class(out, "data.frame")
  expect_equal(out$a, round(df$a, 1))
  # b should be untouched
  expect_identical(out$b, df$b)
})

test_that("round_column() - accepts digits as numeric-like character and integerizes", {
  df <- data.frame(a = c(1.234, 2.345, 3.456))
  out <- round_column(df, "a", "2")   # character "2" should be accepted

  expect_equal(out$a, round(df$a, 2))
})

test_that("round_column() - digits length > 1 or NA should error", {
  df <- data.frame(a = c(1.234, 2.345, 3.456))

  expect_error(round_column(df, "a", c(1, 2)), "`digits` must be a single non-NA numeric value.")
  expect_error(round_column(df, "a", NA), "`digits` must be a single non-NA numeric value.")
})

test_that("round_column() - non-numeric digits should error after coercion", {
  df <- data.frame(a = c(1.234, 2.345, 3.456))

  expect_error(round_column(df, "a", "two"), "`digits` must be numeric.")
})

test_that("round_column() - errors if data is not a data.frame", {
  not_df <- list(a = c(1.2, 3.4))
  expect_error(round_column(not_df, "a", 1), "`data` must be a data.frame.")
})

test_that("round_column() - errors if column does not exist", {
  df <- data.frame(a = c(1.234, 2.345, 3.456))
  expect_error(round_column(df, "missing", 1), "Column 'missing' does not exist in the dataset.")
})

test_that("round_column() - errors if column is not numeric", {
  df <- data.frame(a = c("x", "y", "z"))
  expect_error(
    round_column(df, "a", 1),
    "Column 'a' is not numeric"
  )
})

test_that("round_column() - respects R's round-to-even behavior on ties", {
  # R's round() uses "banker's rounding" (ties to even)
  df <- data.frame(a = c(2.05, 2.15), b = c(2.5, 3.5))
  out1 <- round_column(df, "a", 1)
  # 2.05 -> 2.0; 2.15 -> 2.1
  expect_equal(out1$a, c(2.0, 2.1))

  out2 <- round_column(df, "b", 0)
  expect_equal(out2$b, c(2, 4))
})

test_that("round_column() - preserves NA values", {
  df <- data.frame(a = c(1.234, NA_real_, 3.456))
  out <- round_column(df, "a", 1)
  expect_true(is.na(out$a[2]))
  expect_equal(out$a[c(1,3)], round(df$a[c(1,3)], 1))
})

# ------------------------------------------------------------------------------

test_that("check_decimals() - returns spec unchanged if opts$decimals is NULL", {
  spec <- list(
    data = data.frame(x = 1:3, y = c(1.2, 2.3, 3.4)),
    y = "y"
  )
  opts <- list(decimals = NULL)

  out <- check_decimals(spec, opts, type = "line", extra_args = list())
  expect_identical(out, spec)  # unchanged
})

test_that("check_decimals() - rounds spec$data[[spec$y]] when opts$decimals is set", {
  spec <- list(
    data = data.frame(x = 1:3, y = c(1.234, 2.345, 3.456)),
    y = "y"
  )
  opts <- list(decimals = 1)

  out <- check_decimals(spec, opts, type = "line", extra_args = list())
  expect_equal(out$data$y, round(spec$data$y, 1))
})

test_that("check_decimals() - digits can be numeric-like character", {
  spec <- list(
    data = data.frame(x = 1:3, y = c(1.234, 2.345, 3.456)),
    y = "y"
  )
  opts <- list(decimals = "2")

  out <- check_decimals(spec, opts, type = "line", extra_args = list())
  expect_equal(out$data$y, round(spec$data$y, 2))
})

test_that("check_decimals() - arearange: also rounds ymin and ymax when decimals set", {
  spec <- list(
    data = data.frame(
      x = 1:3,
      mid = c(10.123, 20.234, 30.345),
      ymin = c(9.111, 19.222, 29.333),
      ymax = c(11.111, 21.222, 31.333)
    ),
    y = "mid"
  )
  opts <- list(decimals = 1)
  extra_args <- list(ymin = "ymin", ymax = "ymax")

  out <- check_decimals(spec, opts, type = "arearange", extra_args = extra_args)

  expect_equal(out$data$mid,  round(spec$data$mid,  1))
  expect_equal(out$data$ymin, round(spec$data$ymin, 1))
  expect_equal(out$data$ymax, round(spec$data$ymax, 1))
})

test_that("check_decimals() - arearange: leaves ymin/ymax if decimals is NULL", {
  spec <- list(
    data = data.frame(
      x = 1:3,
      mid = c(10.123, 20.234, 30.345),
      ymin = c(9.111, 19.222, 29.333),
      ymax = c(11.111, 21.222, 31.333)
    ),
    y = "mid"
  )
  opts <- list(decimals = NULL)
  extra_args <- list(ymin = "ymin", ymax = "ymax")

  out <- check_decimals(spec, opts, type = "arearange", extra_args = extra_args)

  expect_identical(out$data, spec$data)
})

test_that("check_decimals() - errors propagate from round_column", {
  # Non-numeric y column triggers error from round_column
  spec <- list(
    data = data.frame(y = c("a", "b")),
    y = "y"
  )
  opts <- list(decimals = 1)

  expect_error(check_decimals(spec, opts, type = "line", extra_args = list()),
               "is not numeric")
})

test_that("check_decimals() - gracefully handles missing ymin/ymax names in arearange", {
  # If y-min/y-max columns are absent, round_column should error. We test that such
  # errors are surfaced (since your function delegates to round_column).
  spec <- list(
    data = data.frame(
      x = 1:3,
      mid = c(10.123, 20.234, 30.345)
      # no ymin/ymax columns
    ),
    y = "mid"
  )
  opts <- list(decimals = 1)
  extra_args <- list(ymin = "ymin", ymax = "ymax")

  expect_error(
    check_decimals(spec, opts, type = "arearange", extra_args = extra_args),
    "does not exist in the dataset"
  )
})
