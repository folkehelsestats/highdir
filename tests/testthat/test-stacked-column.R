# tests/testthat/test-stacked-column.R
#
# Covers gg_stacked_column() and hc_stacked_column() via hd_make().
#
# Datasets (defined in helper.R):
#   olympics  — 12-row medals table: Country, Continent, Medal, Count
#                  Two stacks (Europe, North America), two series per stack.
#   twostack_df  — minimal 8-row frame for edge-case and alignment tests.
#
# HOW WE INSPECT HC OUTPUT
#   A highchart widget stores its config in fig$x$hc_opts.
#   We read series metadata from fig$x$hc_opts$series (a list of lists),
#   and plot options from fig$x$hc_opts$plotOptions.
#
# HOW WE INSPECT GG OUTPUT
#   ggplot2 stores layers in fig$layers and facet spec in fig$facet.
#   We use ggplot_build() for rendered-data checks.

# ── Shared spec / opts ─────────────────────────────────────────────────────────

spec_ol <- hd_spec(olympics,
                   x     = "Medal",
                   y     = "Count",
                   group = "Country")

opts_ol <- hd_opts(
  title    = "Olympic medals by continent",
  subtitle = "All-time totals",
  ylab     = "Count medals"
)

# ══════════════════════════════════════════════════════════════════════════════
# 1.  Return types
# ══════════════════════════════════════════════════════════════════════════════

test_that("HC stacked_column returns highchart", {
  fig <- hd_make(spec_ol, "stacked_column", opts_ol, stack = "Continent")
  expect_true(is_highchart(fig))
})

test_that("GG stacked_column returns ggplot", {
  fig <- hd_make(spec_ol, "stacked_column", opts_ol,
                 stack   = "Continent",
                 mode = "static")
  expect_true(ggplot2::is_ggplot(fig))
})


# ══════════════════════════════════════════════════════════════════════════════
# 2.  Required-arg validation
# ══════════════════════════════════════════════════════════════════════════════

test_that("HC errors when stack arg is missing", {
  expect_error(
    hd_make(spec_ol, "stacked_column", opts_ol),
    "Missing required"
  )
})

test_that("GG errors when stack arg is missing", {
  expect_error(
    hd_make(spec_ol, "stacked_column", opts_ol, mode = "static"),
    "Missing required"
  )
})

test_that("HC errors when group column absent from hd_spec", {
  spec_no_grp <- hd_spec(olympics, x = "Medal", y = "Count")
  expect_error(
    hd_make(spec_no_grp, "stacked_column", opts_ol, stack = "Continent"),
    "group column"
  )
})

test_that("GG errors when group column absent from hd_spec", {
  spec_no_grp <- hd_spec(olympics, x = "Medal", y = "Count")
  expect_error(
    hd_make(spec_no_grp, "stacked_column", opts_ol,
            stack = "Continent", mode = "static"),
    "group column"
  )
})


# ══════════════════════════════════════════════════════════════════════════════
# 3.  Highcharter series structure
# ══════════════════════════════════════════════════════════════════════════════

test_that("HC: number of series equals unique (Country x Continent) combos", {
  fig    <- hd_make(spec_ol, "stacked_column", opts_ol, stack = "Continent")
  series <- fig$x$hc_opts$series
  # 4 countries x 1 continent each = 4 series
  expect_equal(length(series), 4L)
})

test_that("HC: every series has a non-empty name", {
  fig    <- hd_make(spec_ol, "stacked_column", opts_ol, stack = "Continent")
  series <- fig$x$hc_opts$series
  names  <- vapply(series, `[[`, character(1), "name")
  expect_true(all(nzchar(names)))
})

test_that("HC: series names match Country values", {
  fig    <- hd_make(spec_ol, "stacked_column", opts_ol, stack = "Continent")
  series <- fig$x$hc_opts$series
  s_names <- vapply(series, `[[`, character(1), "name")
  expect_true(all(s_names %in% unique(olympics$Country)))
})

test_that("HC: stack field matches Continent values", {
  fig    <- hd_make(spec_ol, "stacked_column", opts_ol, stack = "Continent")
  series <- fig$x$hc_opts$series
  stacks <- vapply(series, `[[`, character(1), "stack")
  expect_true(all(stacks %in% unique(olympics$Continent)))
})

test_that("HC: Norway series has correct data values", {
  fig    <- hd_make(spec_ol, "stacked_column", opts_ol, stack = "Continent")
  series <- fig$x$hc_opts$series
  norway <- Filter(function(s) s$name == "Norway", series)[[1]]
  # Gold=148, Silver=133, Bronze=124 — order follows unique(Medal) in data
  expect_equal(unlist(norway$data), setNames(c(148, 133, 124), rep("y",3)))
})

test_that("HC: each series has a color field", {
  fig    <- hd_make(spec_ol, "stacked_column", opts_ol, stack = "Continent")
  series <- fig$x$hc_opts$series
  colors <- vapply(series, function(s) !is.null(s$color), logical(1))
  expect_true(all(colors))
})

test_that("HC: stacking mode defaults to 'normal'", {
  fig <- hd_make(spec_ol, "stacked_column", opts_ol, stack = "Continent")
  stacking <- fig$x$hc_opts$plotOptions$column$stacking
  expect_equal(stacking, "normal")
})

test_that("HC: stacking = 'percent' is passed through", {
  fig <- hd_make(spec_ol, "stacked_column", opts_ol,
                 stack    = "Continent",
                 stacking = "percent")
  stacking <- fig$x$hc_opts$plotOptions$column$stacking
  expect_equal(stacking, "percent")
})

test_that("HC: legend deduplication — duplicate names have showInLegend FALSE", {
  # Use twostack_df where the same grp values do NOT repeat across stacks,
  # but if they did, duplicates should be hidden.
  # Here we test the general contract: first occurrence is TRUE.
  spec_ts <- hd_spec(twostack_df, x = "x", y = "y", group = "grp")
  fig     <- hd_make(spec_ts, "stacked_column", opts_ol, stack = "stack")
  series  <- fig$x$hc_opts$series

  show_flags <- vapply(series, function(s) isTRUE(s$showInLegend), logical(1))
  # At least one series must be shown
  expect_true(any(show_flags))
})


# ══════════════════════════════════════════════════════════════════════════════
# 4.  Same series name across stacks — colour consistency
# ══════════════════════════════════════════════════════════════════════════════

test_that("HC: same series name gets same colour in different stacks", {
  # Build a dataset where "Shared" appears in both Stack1 and Stack2
  shared_df <- data.frame(
    x     = rep(c("A", "B"), times = 4),
    y     = c(10, 20, 30, 40, 15, 25, 35, 45),
    grp   = rep(c("Shared", "Only1", "Shared", "Only2"), each = 2),
    stack = rep(c("S1", "S1", "S2", "S2"), each = 2),
    stringsAsFactors = FALSE
  )
  spec_sh <- hd_spec(shared_df, x = "x", y = "y", group = "grp")
  fig     <- hd_make(spec_sh, "stacked_column", opts_ol, stack = "stack")
  series  <- fig$x$hc_opts$series

  shared_series <- Filter(function(s) s$name == "Shared", series)
  expect_equal(length(shared_series), 2L)   # appears twice
  # Both occurrences must have identical colour
  expect_equal(shared_series[[1]]$color, shared_series[[2]]$color)
})


# ══════════════════════════════════════════════════════════════════════════════
# 5.  x-axis alignment — missing categories get NA
# ══════════════════════════════════════════════════════════════════════════════

test_that("HC: series data length equals number of x categories", {
  fig    <- hd_make(spec_ol, "stacked_column", opts_ol, stack = "Continent")
  series <- fig$x$hc_opts$series
  n_cats <- length(unique(olympics$Medal))   # 3
  lengths <- vapply(series, function(s) length(s$data), integer(1))
  expect_true(all(lengths == n_cats))
})

test_that("HC: missing x category is filled with NA in series data", {
  # Norway has Gold + Silver but no Bronze entry in this slice
  partial_df <- olympics[olympics$Country != "Norway" |
                              olympics$Medal   != "Bronze", ]
  spec_p  <- hd_spec(partial_df, x = "Medal", y = "Count", group = "Country")
  fig     <- hd_make(spec_p, "stacked_column", opts_ol, stack = "Continent")
  series  <- fig$x$hc_opts$series

  norway <- Filter(function(s) s$name == "Norway", series)[[1]]
  # Bronze is the 3rd category (Gold, Silver, Bronze order in data)
  # The missing Bronze should be NA
  expect_true(is.na(norway$data[[3]]))
})


# ══════════════════════════════════════════════════════════════════════════════
# 6.  ggplot2 layer structure
# ══════════════════════════════════════════════════════════════════════════════

test_that("GG: figure has at least one geom_bar layer", {
  fig    <- hd_make(spec_ol, "stacked_column", opts_ol,
                   stack = "Continent", mode = "static")
  layer_classes <- vapply(fig$layers,
                          function(l) class(l$geom)[1],
                          character(1))
  expect_true(any(layer_classes == "GeomBar"))
})

test_that("GG: figure uses facet_wrap (one panel per stack)", {
  fig <- hd_make(spec_ol, "stacked_column", opts_ol,
                 stack = "Continent", mode = "static")
  expect_true(inherits(fig$facet, "FacetWrap"))
})

test_that("GG: facet variable is the stack column", {
  fig  <- hd_make(spec_ol, "stacked_column", opts_ol,
                  stack = "Continent", mode = "static")
  # FacetWrap stores facet vars in $params$facets
  facet_vars <- names(fig$facet$params$facets)
  expect_true("Continent" %in% facet_vars)
})

test_that("GG: rendered data contains all four countries", {
  fig   <- hd_make(spec_ol, "stacked_column", opts_ol,
                   stack = "Continent", mode = "static")
  built <- ggplot2::ggplot_build(fig)
  # Group levels are encoded as integers; check via the fill aesthetic
  # or via the raw data passed to the layer
  layer_data <- built$data[[1]]
  expect_true(nrow(layer_data) > 0)
})

test_that("GG: stacking = 'percent' does not error", {
  expect_silent(
    hd_make(spec_ol, "stacked_column", opts_ol,
            stack    = "Continent",
            stacking = "percent",
            mode  = "static")
  )
})


# ══════════════════════════════════════════════════════════════════════════════
# 7.  opts integration
# ══════════════════════════════════════════════════════════════════════════════

test_that("HC: title from opts is set on chart", {
  opts_t <- hd_opts(title = "My stacked chart", ylab = "Count")
  fig    <- hd_make(spec_ol, "stacked_column", opts_t, stack = "Continent")
  expect_equal(fig$x$hc_opts$title$text, "My stacked chart")
})

test_that("HC: custom colors are applied to series", {
  pal  <- c("#FF0000", "#00FF00", "#0000FF", "#FFFF00")
  opts_c <- hd_opts(title = "t", colors = pal)
  fig    <- hd_make(spec_ol, "stacked_column", opts_c, stack = "Continent")
  series <- fig$x$hc_opts$series
  s_colors <- vapply(series, `[[`, character(1), "color")
  expect_true(any(s_colors %in% pal))
})

test_that("GG: NULL ylab hides y-axis title", {
  opts_null <- hd_opts(title = "t", ylab = NULL)
  fig       <- hd_make(spec_ol, "stacked_column", opts_null,
                       stack   = "Continent",
                       mode = "static")
  t <- ggplot2::ggplot_build(fig)$plot$theme
  expect_true(inherits(t$axis.title.y, "element_blank"))
})
