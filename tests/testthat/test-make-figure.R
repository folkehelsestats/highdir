spec <- hd_spec(survey_df, "age", "pct", group = "sex", n = "n")
opts <- hd_opts(title = "Test chart", ylim = c(0, 80))

# ── Input validation ──────────────────────────────────────────────────────────

test_that("hd_make: rejects non-hd_spec", {
  expect_error(hd_make(list(), "column"), "hd_spec")
})

test_that("hd_make: NULL opts uses defaults silently", {
  fig <- hd_make(spec, "column", opts = NULL)
  expect_true(is_highchart(fig))
})

test_that("hd_make: unknown geometry errors", {
  expect_error(hd_make(spec, "violin", opts), "Unknown geometry")
})

test_that("hd_make: unknown backend errors", {
  expect_error(hd_make(spec, "column", opts, backend = "plotly"),
               "Unknown backend")
})

test_that("hd_make: arearange requires ymin + ymax", {
  expect_error(hd_make(spec, "arearange", opts), "Missing required")
})

# ── highcharter backend ───────────────────────────────────────────────────────

test_that("hd_make: HC column returns highchart", {
  fig <- hd_make(spec, "column", opts)
  expect_true(is_highchart(fig))
})

test_that("hd_make: HC line (smooth) returns highchart", {
  fig <- hd_make(spec, "line", opts, smooth = TRUE)
  expect_true(is_highchart(fig))
})

test_that("hd_make: HC line (straight) returns highchart", {
  fig <- hd_make(spec, "line", opts, smooth = FALSE)
  expect_true(is_highchart(fig))
})

test_that("hd_make: HC scatter returns highchart", {
  s2  <- hd_spec(survey_df, "pct", "n")
  fig <- hd_make(s2, "scatter", opts)
  expect_true(is_highchart(fig))
})

test_that("hd_make: HC arearange returns highchart", {
  s2  <- hd_spec(survey_df, "age", "pct", group = "sex")
  fig <- hd_make(s2, "arearange", opts, ymin = "lo", ymax = "hi")
  expect_true(is_highchart(fig))
})

test_that("hd_make: HC pie (solid) returns highchart", {
  s2  <- hd_spec(pie_df, "category", "value")
  fig <- hd_make(s2, "pie", hd_opts(title = "Pie"))
  expect_true(is_highchart(fig))
})

test_that("hd_make: HC pie (donut) returns highchart", {
  s2  <- hd_spec(pie_df, "category", "value")
  fig <- hd_make(s2, "pie", hd_opts(title = "Donut"),
                  inner_size = "50%")
  expect_true(is_highchart(fig))
})

test_that("hd_make: use_js = FALSE does not break column", {
  fig <- hd_make(spec, "column", opts, use_js = FALSE)
  expect_true(is_highchart(fig))
})

test_that("hd_make: use_js = FALSE does not break line", {
  fig <- hd_make(spec, "line", opts, use_js = FALSE)
  expect_true(is_highchart(fig))
})

test_that("hd_make: use_js = FALSE does not break pie", {
  s2  <- hd_spec(pie_df, "category", "value")
  fig <- hd_make(s2, "pie", hd_opts(), use_js = FALSE)
  expect_true(is_highchart(fig))
})

# ── ggplot2 backend ───────────────────────────────────────────────────────────

test_that("hd_make: gg column returns ggplot", {
  fig <- hd_make(spec, "column", opts, backend = "ggplot2")
  expect_true(is_ggplot(fig))
})

test_that("hd_make: gg line returns ggplot", {
  fig <- hd_make(spec, "line", opts, backend = "ggplot2", smooth = FALSE)
  expect_true(is_ggplot(fig))
})

test_that("hd_make: gg scatter returns ggplot", {
  s2  <- hd_spec(survey_df, "pct", "n")
  fig <- hd_make(s2, "scatter", opts, backend = "ggplot2")
  expect_true(is_ggplot(fig))
})

test_that("hd_make: gg arearange returns ggplot", {
  s2  <- hd_spec(survey_df, "age", "pct", group = "sex")
  fig <- hd_make(s2, "arearange", opts, backend = "ggplot2",
                  ymin = "lo", ymax = "hi")
  expect_true(is_ggplot(fig))
})

test_that("hd_make: gg pie returns ggplot", {
  s2  <- hd_spec(pie_df, "category", "value")
  fig <- hd_make(s2, "pie", hd_opts(title = "Pie"),
                  backend = "ggplot2")
  expect_true(is_ggplot(fig))
})

# ── hd_opts reuse ────────────────────────────────────────────────────────────

test_that("same spec renders with two different opts", {
  opts_a <- hd_opts(title = "A", ylim = c(0, 60))
  opts_b <- hd_opts(title = "B", flip = TRUE)
  expect_true(is_highchart(hd_make(spec, "column", opts_a)))
  expect_true(is_highchart(hd_make(spec, "column", opts_b)))
})

# ── Per-figure colour override ────────────────────────────────────────────────

test_that("hd_make: per-figure colors in opts work for both backends", {
  o <- hd_opts(colors = c("#FF0000", "#0000FF"))
  expect_true(is_highchart(hd_make(spec, "column", o)))
  expect_true(is_ggplot(hd_make(spec, "column", o, backend = "ggplot2")))
})

# ── Line-specific args ────────────────────────────────────────────────────────

test_that("hd_make: line with custom dot_size and line_symbols", {
  fig <- hd_make(spec, "line", opts,
                  smooth       = FALSE,
                  dot_size     = 8,
                  line_symbols = c("circle", "square"))
  expect_true(is_highchart(fig))
})

# ── No-group specs ────────────────────────────────────────────────────────────

test_that("hd_make: works without group column", {
  s_ng <- hd_spec(survey_df[survey_df$sex == "Male", ],
                   "age", "pct")
  expect_true(is_highchart(hd_make(s_ng, "column", opts)))
  expect_true(is_ggplot(hd_make(s_ng, "column", opts, backend = "ggplot2")))
})

# ── Modules ────────────────────────────────────────────────────────────
test_that("hd_make: modules = TRUE adds accessibility dependency", {
  spec <- hd_spec(data.frame(x = c("A","B"), y = c(1,2)), "x", "y")
  fig  <- hd_make(spec, "column", hd_opts(), module = TRUE)
  deps <- vapply(fig$dependencies, function(d) d$name, character(1))
  expect_true(any(grepl("accessibility", deps, ignore.case = TRUE)))
})

test_that("hd_make: modules = FALSE skips standard dependencies", {
  spec <- hd_spec(data.frame(x = c("A","B"), y = c(1,2)), "x", "y")
  fig  <- hd_make(spec, "column", hd_opts(), module = FALSE)
  deps <- vapply(fig$dependencies, function(d) d$name, character(1))
  expect_false(any(grepl("accessibility", deps, ignore.case = TRUE)))
})

test_that("hd_make: modules ignored silently for ggplot2 backend", {
  spec <- hd_spec(data.frame(x = c("A","B"), y = c(1,2)), "x", "y")
  expect_s3_class(
    hd_make(spec, "column", hd_opts(),
            backend = "ggplot2", module = FALSE),
    "ggplot"
  )
})
