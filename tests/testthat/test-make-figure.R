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

test_that("invalid mode fails", {
  expect_snapshot(
    error = TRUE,
    normalize_mode("plotly")
  )
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
  fig <- hd_make(spec, "column", opts, mode = "static")
  expect_true(is_ggplot(fig))
})

test_that("hd_make: gg line returns ggplot", {
  fig <- hd_make(spec, "line", opts, mode = "static", smooth = FALSE)
  expect_true(is_ggplot(fig))
})

test_that("hd_make: gg scatter returns ggplot", {
  s2  <- hd_spec(survey_df, "pct", "n")
  fig <- hd_make(s2, "scatter", opts, mode = "static")
  expect_true(is_ggplot(fig))
})

test_that("hd_make: gg arearange returns ggplot", {
  s2  <- hd_spec(survey_df, "age", "pct", group = "sex")
  fig <- hd_make(s2, "arearange", opts, mode = "static",
                  ymin = "lo", ymax = "hi")
  expect_true(is_ggplot(fig))
})

test_that("hd_make: gg pie returns ggplot", {
  s2  <- hd_spec(pie_df, "category", "value")
  fig <- hd_make(s2, "pie", hd_opts(title = "Pie"),
                  mode = "static")
  expect_true(is_ggplot(fig))
})

# ── ggplot2 colors and palettes ──────────────────────────────────────────────────

test_that("gg n=2 uses hdir2 not hdir[1:2]", {
  fig   <- hd_make(spec2, "column", hd_opts(), mode = "static")
  fills <- .extract_gg_fill_values(fig)
  hdir2 <- get_palette("hdir2")
  expect_equal(sort(unname(fills)), sort(hdir2[1:2]))
  expect_false(identical(sort(unname(fills)),
                          sort(get_palette("hdir")[1:2])))
})

test_that("gg and HC assign same colour to same group", {
  fig_hc <- hd_make(spec2, "column", hd_opts())
  fig_gg <- hd_make(spec2, "column", hd_opts(), mode = "static")

  hc_male <- fig_hc$x$hc_opts$series[[
    which(vapply(fig_hc$x$hc_opts$series,
                 function(s) s$name == "Male", logical(1)))
  ]]$color

  gg_fills <- .extract_gg_fill_values(fig_gg)
  expect_equal(gg_fills[["Male"]], hc_male)
})

test_that("gg palette name string resolved not passed raw", {
  # Previously crashed with scale_color_manual(values = "hdir")
  expect_s3_class(
    hd_make(spec2, "column", hd_opts(colors = "hdir"), mode = "static"),
    "ggplot"
  )
})

test_that("gg too-short palette warns and falls back", {
  expect_warning(
    hd_make(spec2, "column", hd_opts(colors = "#FF0000"),
            mode = "static"),
    "Falling back"
  )
})

# --- ggplot2 with single color ----------------------

test_that("gg single series bar uses hdir[1] colour", {
  spec <- hd_spec(data.frame(year = 2018:2022, val = c(1,2,3,4,5)),
                  "year", "val")
  fig  <- hd_make(spec, "column", hd_opts(), mode = "static")
  expect_equal(.layer_aes(fig, "GeomCol", "fill"), get_palette("hdir")[1])
})

test_that("gg line single series uses hdir[1]", {
  spec <- hd_spec(data.frame(year = 2018:2022, val = c(1,2,3,4,5)),
                  "year", "val")
  fig  <- hd_make(spec, "line", hd_opts(), mode = "static")
  expect_equal(.layer_aes(fig, "GeomLine", "colour"), get_palette("hdir")[1])
})

test_that("gg scatter single series uses hdir[1]", {
  spec <- hd_spec(data.frame(year = 2018:2022, val = c(1,2,3,4,5)),
                  "year", "val")
  fig  <- hd_make(spec, "scatter", hd_opts(), mode = "static")
  expect_equal(.layer_aes(fig, "GeomPoint", "colour"), get_palette("hdir")[1])
})

test_that("gg single series does not add fill or colour scales", {
  spec <- hd_spec(data.frame(year = 2018:2022, val = c(1,2,3,4,5)),
                  "year", "val")
  fig  <- hd_make(spec, "column", hd_opts(), mode = "static")

  scale_aes <- unlist(lapply(fig$scales$scales, function(s) s$aesthetics))
  expect_false("fill"   %in% scale_aes)
  expect_false("colour" %in% scale_aes)
})

test_that("gg single series explicit colour override respected", {
  spec <- hd_spec(data.frame(year = 2018:2022, val = c(1,2,3,4,5)),
                  "year", "val")
  fig  <- hd_make(spec, "column", hd_opts(colors = "#FF0000"),
                  mode = "static")

  layer_fill <- .layer_aes(fig, "GeomCol", "colour")
  expect_equal(layer_fill, "#FF0000")
})

test_that("gg multi-series still uses apply_gg_colors", {
  df <- data.frame(
    year = rep(2018:2020, 2),
    val  = c(1,2,3,4,5,6),
    grp  = rep(c("A","B"), each = 3)
  )
  spec <- hd_spec(df, "year", "val", group = "grp")
  fig  <- hd_make(spec, "column", hd_opts(), mode = "static")

  scale_aes <- unlist(lapply(fig$scales$scales, function(s) s$aesthetics))
  expect_true("fill" %in% scale_aes)
})

# -- ggplot2 multi colors

test_that("gg multi-series column uses hdir2 not grey", {
  df <- data.frame(
    year = rep(2018:2020, 2),
    val  = c(1,2,3,4,5,6),
    grp  = rep(c("A","B"), each = 3)
  )
  spec <- hd_spec(df, "year", "val", group = "grp")
  fig  <- hd_make(spec, "column", hd_opts(), mode = "static")

  # Fill scale must exist — means apply_gg_colors was called
  scale_aes <- unlist(lapply(fig$scales$scales, function(s) s$aesthetics))
  expect_true("fill" %in% scale_aes)

  # The geom layer must NOT have a fixed fill — it must inherit from mapping
  col_layer_idx <- .find_layers(fig, "GeomCol")
  layer_fill    <- fig$layers[[col_layer_idx[1]]]$aes_params$fill
  expect_null(layer_fill)   # NULL = not fixed, inherits mapped aesthetic
})

test_that("gg single series column has no fill scale", {
  spec <- hd_spec(data.frame(year = 2018:2022, val = c(1,2,3,4,5)),
                  "year", "val")
  fig  <- hd_make(spec, "column", hd_opts(), mode = "static")

  scale_aes <- unlist(lapply(fig$scales$scales, function(s) s$aesthetics))
  expect_false("fill" %in% (scale_aes %||% character(0)))

  # Fixed colour is on the layer itself
  expect_equal(.layer_aes(fig, "GeomCol", "fill"), get_palette("hdir")[1])
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
  expect_true(is_ggplot(hd_make(spec, "column", o, mode = "static")))
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
  expect_true(is_ggplot(hd_make(s_ng, "column", opts, mode = "static")))
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
            mode = "static", module = FALSE),
    "ggplot"
  )
})

## -- Axis labelling --------
test_that("HC: default opts uses column name as y label", {
  spec <- hd_spec(data.frame(x = c("A","B"), rate = c(1,2)), "x", "rate")
  fig  <- hd_make(spec, "column", hd_opts())
  expect_equal(fig$x$hc_opts$yAxis$title$text, "rate")
})

test_that("HC: NULL ylab hides y axis title", {
  spec <- hd_spec(data.frame(x = c("A","B"), rate = c(1,2)), "x", "rate")
  fig  <- hd_make(spec, "column", hd_opts(ylab = NULL))
  expect_equal(fig$x$hc_opts$yAxis$title$text, "")
})

test_that("HC: custom ylab used as axis title", {
  spec <- hd_spec(data.frame(x = c("A","B"), rate = c(1,2)), "x", "rate")
  fig  <- hd_make(spec, "column", hd_opts(ylab = "Rate per 100 000"))
  expect_equal(fig$x$hc_opts$yAxis$title$text, "Rate per 100 000")
})

test_that("gg: NULL ylab applies element_blank to axis.title.y", {
  spec <- hd_spec(data.frame(x = c("A","B"), rate = c(1,2)), "x", "rate")
  fig  <- hd_make(spec, "column", hd_opts(ylab = NULL), mode = "static")
  expect_s3_class(fig$theme$axis.title.y, "element")
})
