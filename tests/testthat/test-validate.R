spec <- hd_spec(survey_df, "age", "pct")
opts <- hd_opts()

test_that("validate_fig_inputs: passes for all valid inputs", {
  expect_invisible(
    validate_fig_inputs(spec, opts, "column", "highcharter", list()))
})

test_that("validate_fig_inputs: rejects non-hd_spec", {
  expect_error(
    validate_fig_inputs(list(), opts, "column", "highcharter", list()),
    "hd_spec")
})

test_that("validate_fig_inputs: rejects non-hd_opts", {
  expect_error(
    validate_fig_inputs(spec, list(), "column", "highcharter", list()),
    "hd_opts")
})

test_that("validate_fig_inputs: rejects unknown geometry", {
  expect_error(
    validate_fig_inputs(spec, opts, "violin", "highcharter", list()),
    "Unknown geometry")
})

test_that("validate_fig_inputs: rejects unknown backend", {
  expect_error(
    validate_fig_inputs(spec, opts, "column", "plotly", list()),
    "Unknown backend")
})

test_that("validate_fig_inputs: enforces required geometry args", {
  expect_error(
    validate_fig_inputs(spec, opts, "arearange", "highcharter", list()),
    "Missing required")
  expect_invisible(
    validate_fig_inputs(spec, opts, "arearange", "highcharter",
                        list(ymin = "lo", ymax = "hi")))
})

test_that("validate_fig_inputs: pie has no required args", {
  expect_invisible(
    validate_fig_inputs(spec, opts, "pie", "highcharter", list()))
})
