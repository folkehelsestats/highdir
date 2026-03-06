test_that("%||% returns left when non-NULL", {
  expect_equal("a" %||% "b", "a")
  expect_equal(0L  %||% 99L, 0L)
  expect_equal(FALSE %||% TRUE, FALSE)
})

test_that("%||% returns right when NULL", {
  expect_equal(NULL %||% "b",   "b")
  expect_equal(NULL %||% 42,    42)
  expect_equal(NULL %||% FALSE, FALSE)
})

test_that("is_highchart / is_ggplot predicates", {
  p <- ggplot2::ggplot()
  expect_true(is_ggplot(p))
  expect_false(is_highchart(p))
  expect_false(is_ggplot(list()))
  expect_false(is_highchart(list()))
})

test_that("check_columns: passes for present columns", {
  df <- data.frame(a = 1, b = 2)
  expect_invisible(check_columns(df, c("a", "b")))
})

test_that("check_columns: stops with informative message for missing", {
  df <- data.frame(a = 1)
  expect_error(check_columns(df, c("a", "z")), "z")
  expect_error(check_columns(df, "missing"),    "missing")
})

test_that("check_columns: NULL values in cols vector are ignored", {
  df <- data.frame(a = 1)
  expect_invisible(check_columns(df, NULL))
  expect_invisible(check_columns(df, c("a", NULL)))
})

test_that("check_ylim: passes NULL and valid ranges", {
  expect_invisible(check_ylim(NULL))
  expect_invisible(check_ylim(c(0, 100)))
  expect_invisible(check_ylim(c(-10, 10)))
})

test_that("check_ylim: fails on bad inputs", {
  expect_error(check_ylim(c(100, 0)),    "ylim\\[1\\]")
  expect_error(check_ylim(c(0, 0)),      "ylim\\[1\\]")
  expect_error(check_ylim(c(1, 2, 3)),   "length 2")
  expect_error(check_ylim("text"),        "length 2")
})

test_that("resolve_symbols: defaults recycle .hc_symbols", {
  s3 <- resolve_symbols(3)
  expect_length(s3, 3)
  expect_true(all(s3 %in% .hc_symbols))
})

test_that("resolve_symbols: warns on invalid symbols and falls back", {
  expect_warning(resolve_symbols(2, c("hexagon")), "Invalid")
})

test_that("resolve_symbols: warns on length mismatch and recycles", {
  expect_warning(resolve_symbols(4, c("circle", "square")), "Recycling")
})

## --- Axis labeling --
test_that(".resolve_axis_label: sentinel returns column name", {
  expect_equal(highdir:::.resolve_axis_label(" ", "rate"), "rate")
})

test_that(".resolve_axis_label: NULL returns NULL", {
  expect_null(highdir:::.resolve_axis_label(NULL, "rate"))
})

test_that(".resolve_axis_label: custom string returned as-is", {
  expect_equal(
    highdir:::.resolve_axis_label("Rate per 100 000", "rate"),
    "Rate per 100 000"
  )
})
