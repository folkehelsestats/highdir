test_that("built-in geoms registered at load", {
  g <- list_geoms()
  expect_true(all(c("column", "line", "scatter", "arearange", "pie") %in% g))
})

test_that("built-in backends registered at load", {
  b <- list_backends()
  expect_true(all(c("ggplot2", "highcharter") %in% b))
})

test_that("register_backend / get_backend round-trip", {
  eng <- function(spec, geom, opts, geom_params, use_js, filename, ...) NULL
  register_backend("test_backend", eng)
  expect_true("test_backend" %in% list_backends())
  expect_identical(get_backend("test_backend"), eng)
})

test_that("register_backend: rejects non-function", {
  expect_error(register_backend("bad", "oops"), "function")
})

test_that("register_geom / .get_geom round-trip", {
  register_geom("test_geom",
    ggplot_fun      = function(spec, opts, gp, ...) list(),
    highcharter_fun = function(chart, spec, opts, gp, ...) chart,
    required_args   = c("foo")
  )
  expect_true("test_geom" %in% list_geoms())
  g <- .get_geom("test_geom")
  expect_equal(g$required_args, "foo")
  expect_true(is.function(g$ggplot_fun))
})

test_that("validate_geom_args: passes when all required present", {
  g <- list(required_args = c("ymin", "ymax"))
  expect_invisible(validate_geom_args(g, list(ymin = "a", ymax = "b")))
})

test_that("validate_geom_args: stops on missing required args", {
  g <- list(required_args = list(ymin = NULL, ymax = NULL))
  expect_error(validate_geom_args(g, list()), "Missing required")
  expect_error(validate_geom_args(g, list(ymin = "a")), "ymax")
})

test_that("arearange has correct required_args", {
  g <- .get_geom("arearange")
  expect_setequal(names(g$required_args), c("ymin", "ymax"))
})

test_that("pie has no required_args", {
  expect_length(.get_geom("pie")$required_args, 0)
})
