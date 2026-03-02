test_that("fig_spec validates columns", {
  df <- data.frame(a = 1:3, b = 1:3)
  expect_error(fig_spec(df, "a", "z"), "Column\\(s\\) not found")
  expect_s3_class(fig_spec(df, "a", "b"), "fig_spec")
})

test_that("fig_spec validates ylim", {
  df <- data.frame(a = 1:3, b = 1:3)
  expect_error(fig_spec(df, "a", "b", ylim = c(100, 0)), "ylim\\[1\\]")
  expect_error(fig_spec(df, "a", "b", ylim = c(0)),       "length 2")
})

test_that("print.fig_spec runs without error", {
  df   <- data.frame(x = 1:3, y = 1:3)
  spec <- fig_spec(df, "x", "y", title = "test")
  expect_output(print(spec), "fig_spec")
  expect_output(print(spec), "title")
})

test_that("list_geoms returns at least the four built-in geoms", {
  geoms <- list_geoms()
  expect_true(all(c("line", "column", "scatter", "arearange") %in% geoms))
})

test_that("list_backends returns at least ggplot2 and highcharter", {
  backends <- list_backends()
  expect_true(all(c("ggplot2", "highcharter") %in% backends))
})

test_that("make_fig rejects non-fig_spec input", {
  expect_error(make_fig(list(), "column"), "fig_spec")
})

test_that("make_fig rejects unknown geometry", {
  df   <- data.frame(x = 1:3, y = 1:3)
  spec <- fig_spec(df, "x", "y")
  expect_error(make_fig(spec, "unknown_geom"), "Unknown geometry")
})

test_that("make_fig rejects unknown backend", {
  df   <- data.frame(x = 1:3, y = 1:3)
  spec <- fig_spec(df, "x", "y")
  expect_error(make_fig(spec, "column", backend = "unknown"), "Unknown backend")
})

test_that("make_fig arearange requires ymin and ymax", {
  df   <- data.frame(x = 1:3, y = 1:3, lo = 0:2, hi = 2:4)
  spec <- fig_spec(df, "x", "y")
  expect_error(make_fig(spec, "arearange"), "Missing required argument")
})

test_that("resolve_colors returns correct length", {
  expect_length(resolve_colors(2),  2)
  expect_length(resolve_colors(5),  5)
  expect_length(resolve_colors(10), 10)
})

test_that("resolve_symbols recycles and warns on length mismatch", {
  expect_length(resolve_symbols(3),           3)
  expect_length(resolve_symbols(7),           7)
  expect_warning(resolve_symbols(3, c("circle", "square")), "Recycling")
})

test_that("hd_set_theme sets and restores options", {
  prev <- hd_set_theme(hc_theme = "darkunica")
  expect_equal(getOption("highdir.hc_theme"), "darkunica")
  options(prev)   # restore
  expect_equal(getOption("highdir.hc_theme"), "default")
})

test_that("hd_add_js rejects missing code/file/plugin", {
  hc <- highcharter::highchart()
  expect_error(hd_add_js(hc), "Supply exactly one")
})

test_that("hd_save returns file path invisibly", {
  df   <- data.frame(x = 1:3, y = 1:3)
  spec <- fig_spec(df, "x", "y")
  p    <- make_fig(spec, "scatter", backend = "ggplot2")
  tmp  <- tempfile(fileext = ".png")
  on.exit(unlink(tmp))
  result <- hd_save(p, tmp)
  expect_equal(result, tmp)
  expect_true(file.exists(tmp))
})
