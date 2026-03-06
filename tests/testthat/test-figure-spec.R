# ── hd_spec ──────────────────────────────────────────────────────────────────
test_that("hd_spec: no longer accepts xlab/ylab", {
  expect_error(
    hd_spec(data.frame(x=1, y=1), "x", "y", ylab = "Rate"),
    "unused argument"
  )
})

test_that("hd_spec: constructs with correct class and fields", {
  spec <- hd_spec(survey_df, x = "age", y = "pct")
  expect_s3_class(spec, "hd_spec")
  expect_equal(spec$x,    "age")
  expect_equal(spec$y,    "pct")
  expect_null(spec$group)
  expect_null(spec$n)
  expect_equal(nrow(spec$data), nrow(survey_df))
})

test_that("hd_spec: rejects non-data.frame", {
  expect_error(hd_spec(list(x = 1), "x", "x"), "data.frame")
})

test_that("hd_spec: stops on missing columns", {
  expect_error(hd_spec(survey_df, "age", "missing"),       "missing")
  expect_error(hd_spec(survey_df, "age", "pct", group = "nope"), "nope")
  expect_error(hd_spec(survey_df, "age", "pct", n = "nope"),     "nope")
})

test_that("hd_spec: strips tibble subclass (stores plain data.frame)", {
  skip_if_not_installed("tibble")
  tbl  <- tibble::as_tibble(survey_df)
  spec <- hd_spec(tbl, "age", "pct")
  expect_true(is.data.frame(spec$data))
  expect_false(inherits(spec$data, "tbl_df"))
})

test_that("hd_spec: print output contains key fields", {
  spec <- hd_spec(survey_df, "age", "pct", group = "sex", n = "n")
  expect_output(print(spec), "hd_spec")
  expect_output(print(spec), "group")
  expect_output(print(spec), "rows")
})

test_that("hd_spec: as.list replaces data with descriptive string", {
  spec <- hd_spec(survey_df, "age", "pct")
  lst  <- as.list(spec)
  expect_true(is.character(lst$data))
  expect_match(lst$data, "data.frame")
})

# ── fig_opts ──────────────────────────────────────────────────────────────────

test_that("hd_opts: constructs with correct defaults", {
  opts <- hd_opts()
  expect_s3_class(opts, "hd_opts")
  expect_null(opts$title)
  expect_equal(opts$yint, 10)
  expect_false(opts$flip)
})

test_that("hd_opts: stores all fields", {
  opts <- hd_opts(title = "T", subtitle = "S", caption = "C",
                   ylim = c(0, 100), yint = 20, flip = TRUE,
                   colors = "#FF0000", hc_theme = "bloom")
  expect_equal(opts$title,    "T")
  expect_equal(opts$ylim,     c(0, 100))
  expect_equal(opts$yint,     20)
  expect_true(opts$flip)
  expect_equal(opts$hc_theme, "bloom")
})

test_that("hd_opts: validates ylim", {
  expect_error(hd_opts(ylim = c(100, 0)),  "ylim\\[1\\]")
  expect_error(hd_opts(ylim = c(0)),        "length 2")
  expect_silent(hd_opts(ylim = c(0, 100)))
})

test_that("hd_opts: validates yint", {
  expect_error(hd_opts(yint = 0),  "positive")
  expect_error(hd_opts(yint = -5), "positive")
  expect_silent(hd_opts(yint = 1))
})

test_that("hd_opts: print works", {
  opts <- hd_opts(title = "Test", ylim = c(0, 80))
  expect_output(print(opts), "hd_opts")
  expect_output(print(opts), "title")
  expect_output(print(opts), "ylim")
})

test_that("hd_opts: as.list returns plain list", {
  opts <- hd_opts(title = "T", yint = 5)
  lst  <- as.list(opts)
  expect_type(lst, "list")
  expect_equal(lst$title, "T")
  expect_equal(lst$yint,  5)
})

test_that("default_opts returns hd_opts with defaults", {
  expect_s3_class(default_opts(), "hd_opts")
  expect_equal(default_opts()$yint, 10)
})

test_that("hd_opts: default ylab is sentinel ' '", {
  opts <- hd_opts()
  expect_equal(opts$ylab, " ")
})

test_that("hd_opts: NULL ylab preserved as NULL", {
  opts <- hd_opts(ylab = NULL)
  expect_null(opts$ylab)
})

test_that("hd_opts: custom ylab stored correctly", {
  opts <- hd_opts(ylab = "Rate per 100 000")
  expect_equal(opts$ylab, "Rate per 100 000")
})
