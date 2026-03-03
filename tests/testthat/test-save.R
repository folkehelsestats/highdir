spec <- hd_spec(survey_df[survey_df$sex == "Male", ], "age", "pct")
opts <- fig_opts(title = "Save test")

# ── Helpers ───────────────────────────────────────────────────────────────────
new_tmp <- function(ext) {
  f <- tempfile(fileext = paste0(".", ext))
  withr::defer(unlink(f), envir = parent.frame())
  f
}

# ── ggplot2 saves ─────────────────────────────────────────────────────────────

test_that("hd_save: ggplot2 PNG written to disk", {
  fig <- hd_make(spec, "column", opts, backend = "ggplot2")
  f   <- new_tmp("png")
  expect_equal(hd_save(fig, f), f)
  expect_true(file.exists(f))
  expect_gt(file.size(f), 100)
})

test_that("hd_save: ggplot2 SVG written to disk", {
  fig <- hd_make(spec, "column", opts, backend = "ggplot2")
  f   <- new_tmp("svg")
  hd_save(fig, f)
  expect_true(file.exists(f))
  expect_gt(file.size(f), 100)
})

test_that("hd_save: works with raw ggplot (no hd_fig class)", {
  p <- ggplot2::ggplot(survey_df, ggplot2::aes(age, pct)) +
         ggplot2::geom_col()
  f <- new_tmp("png")
  expect_invisible(hd_save(p, f))
  expect_true(file.exists(f))
})

test_that("hd_save: explicit type override works (no extension)", {
  fig <- hd_make(spec, "column", opts, backend = "ggplot2")
  f   <- tempfile()              # no extension
  withr::defer(unlink(f))
  hd_save(fig, f, type = "png")
  expect_true(file.exists(f))
})

test_that("hd_save: ggplot2 unsupported format errors", {
  fig <- hd_make(spec, "column", opts, backend = "ggplot2")
  expect_error(hd_save(fig, "out.xyz"), "Unsupported format")
})

# ── highcharter saves ─────────────────────────────────────────────────────────

test_that("hd_save: highcharter HTML written to disk", {
  fig <- hd_make(spec, "column", opts)
  f   <- new_tmp("html")
  hd_save(fig, f)
  expect_true(file.exists(f))
  expect_gt(file.size(f), 1000)
})

test_that("hd_save: highcharter JSON is valid JSON", {
  fig <- hd_make(spec, "column", opts)
  f   <- new_tmp("json")
  hd_save(fig, f)
  expect_true(file.exists(f))
  cfg <- jsonlite::read_json(f)
  expect_type(cfg, "list")
})

test_that("hd_save: highcharter unsupported format errors", {
  fig <- hd_make(spec, "column", opts)
  expect_error(hd_save(fig, "out.svg"), "Unsupported format")
})

# ── Error cases ───────────────────────────────────────────────────────────────

test_that("hd_save: errors when fig is not highchart or ggplot", {
  expect_error(hd_save(list(), "out.png"), "highchart or ggplot")
})

test_that("hd_save: errors when file has no extension and type = 'auto'", {
  fig <- hd_make(spec, "column", opts, backend = "ggplot2")
  expect_error(hd_save(fig, "no_extension"), "no file extension")
})

# ── Pie charts can be saved ───────────────────────────────────────────────────

test_that("hd_save: pie ggplot2 to PNG", {
  s2  <- hd_spec(pie_df, "category", "value")
  fig <- hd_make(s2, "pie", fig_opts(title = "Pie"), backend = "ggplot2")
  f   <- new_tmp("png")
  hd_save(fig, f)
  expect_true(file.exists(f))
})

test_that("hd_save: pie highcharter to HTML", {
  s2  <- hd_spec(pie_df, "category", "value")
  fig <- hd_make(s2, "pie", fig_opts(title = "Pie"))
  f   <- new_tmp("html")
  hd_save(fig, f)
  expect_true(file.exists(f))
})
