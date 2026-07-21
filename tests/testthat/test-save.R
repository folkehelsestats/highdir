# tests/testthat/test-save.R

spec   <- hd_spec(data.frame(x = c("A","B"), y = c(1,2)), "x", "y")
fig_hc <- hd_make(spec, "column", hd_opts())
fig_gg <- hd_make(spec, "column", hd_opts(), mode = "static")

# ── HC: allowed ───────────────────────────────────────────────────────────────
test_that("hd_save: HC to HTML works", {
  f <- tempfile(fileext = ".html")
  withr::defer(unlink(f))
  expect_invisible(hd_save(fig_hc, f))
  expect_true(file.exists(f))
})

test_that("hd_save: HC to JSON works", {
  f <- tempfile(fileext = ".json")
  withr::defer(unlink(f))
  hd_save(fig_hc, f)
  expect_true(file.exists(f))
  expect_true(is.list(jsonlite::read_json(f)))
})

# ── HC: blocked — clear error pointing to ggplot2 path ───────────────────────
test_that("hd_save: HC to PNG errors with ggplot2 suggestion", {
  expect_error(
    hd_save(fig_hc, "chart.png"),
    regexp = "not supported for highcharter"
  )
})

test_that("hd_save: HC to PDF errors", {
  expect_error(hd_save(fig_hc, "chart.pdf"), "not supported for highcharter")
})

test_that("hd_save: HC to SVG errors", {
  expect_error(hd_save(fig_hc, "chart.svg"), "not supported for highcharter")
})

# ── ggplot2: allowed ──────────────────────────────────────────────────────────
test_that("hd_save: gg to PNG works", {
  f <- tempfile(fileext = ".png")
  withr::defer(unlink(f))
  hd_save(fig_gg, f)
  expect_true(file.exists(f))
})

test_that("hd_save: gg to PDF works", {
  f <- tempfile(fileext = ".pdf")
  withr::defer(unlink(f))
  hd_save(fig_gg, f)
  expect_true(file.exists(f))
})

test_that("hd_save: gg to SVG works", {
  skip_if_not_installed("svglite")
  f <- tempfile(fileext = ".svg")
  withr::defer(unlink(f))
  hd_save(fig_gg, f)
  expect_true(file.exists(f))
})

# ── Bad inputs ────────────────────────────────────────────────────────────────
test_that("hd_save: no extension errors", {
  expect_error(hd_save(fig_hc, "chart"), "no file extension")
})

test_that("hd_save: non-figure object errors", {
  expect_error(hd_save(list(a = 1), "chart.html"), "must be a highchart")
})

test_that("hd_save: returns file path invisibly", {
  f <- tempfile(fileext = ".html")
  withr::defer(unlink(f))
  result <- hd_save(fig_hc, f)
  expect_equal(result, f)
})

