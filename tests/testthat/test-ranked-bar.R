# tests/testthat/test-ranked-bar.R
#
# Covers: gg_ranked_bar, hc_ranked_bar, hd_make("ranked_bar", ...)
#
# Dataset: 20 Norwegian municipalities with rate + population count.
# Using a fixed seed-free frame (deterministic values) so tests never flicker.

muni_df <- data.frame(
  municipality = c(
    "Oslo", "Bergen", "Trondheim", "Stavanger", "Kristiansand",
    "Tromsø", "Drammen", "Fredrikstad", "Sandnes", "Sarpsborg",
    "Bodø", "Sandefjord", "Ålesund", "Skien", "Haugesund",
    "Tønsberg", "Moss", "Porsgrunn", "Arendal", "Hamar"
  ),
  rate = c(
    112.4,  98.7,  87.3, 104.1,  76.5,
     91.2,  83.6,  79.8,  95.3,  68.2,
     88.9,  72.4,  81.1,  65.7,  93.8,
     70.3,  74.6,  61.9,  78.2,  85.5
  ),
  pop_count = c(
    693494, 285911, 205849, 144475,  96172,
     77983,  98088,  83193,  84025,  60817,
     52678,  47064,  47160,  52520,  46890,
     56732,  51240,  35087,  46031,  31345
  ),
  stringsAsFactors = FALSE
)

# ── Shared spec/opts ──────────────────────────────────────────────────────────

spec_n  <- hd_spec(muni_df, x = "municipality", y = "rate", n = "pop_count")
spec_no_n <- hd_spec(muni_df, x = "municipality", y = "rate")
opts    <- hd_opts(title = "Rate by municipality", ylab = "Rate per 100 000")


# ═══════════════════════════════════════════════════════════════════════════════
# 1. Return types
# ═══════════════════════════════════════════════════════════════════════════════

test_that("gg ranked_bar returns ggplot", {
  fig <- hd_make(spec_n, "ranked_bar", opts, backend = "ggplot2")
  expect_true(ggplot2::is_ggplot(fig))
})

test_that("hc ranked_bar returns highchart", {
  fig <- hd_make(spec_n, "ranked_bar", opts, backend = "highcharter")
  expect_true(highcharter::is.highchart(fig))
})

test_that("gg ranked_bar works without spec$n", {
  fig <- hd_make(spec_no_n, "ranked_bar", opts, backend = "ggplot2")
  expect_true(ggplot2::is_ggplot(fig))
})

test_that("hc ranked_bar works without spec$n", {
  fig <- hd_make(spec_no_n, "ranked_bar", opts, backend = "highcharter")
  expect_true(highcharter::is.highchart(fig))
})


# ═══════════════════════════════════════════════════════════════════════════════
# 2. Sorting — gg backend
#    gg_ranked_bar builds a sorted factor on .xname; the factor levels encode
#    the sort order. We inspect them directly from the layer data.
# ═══════════════════════════════════════════════════════════════════════════════

.gg_xlevels <- function(fig) {
  # Find the geom_bar layer and extract .xname factor levels from its data
  bar_idx <- which(vapply(fig$layers, function(l)
    inherits(l$geom, "GeomBar"), logical(1)))
  stopifnot(length(bar_idx) == 1L)
  levels(fig$layers[[bar_idx]]$data$.xname)
}

test_that("gg: ascending = TRUE puts lowest rate first in factor levels", {
  fig    <- hd_make(spec_n, "ranked_bar", opts,
                    backend = "ggplot2", ascending = TRUE)
  lvls   <- .gg_xlevels(fig)
  # In ggplot2 with coord_flip the first factor level = bottom bar = lowest value
  # Porsgrunn has the lowest rate (61.9)
  expect_equal(lvls[1], "Porsgrunn (N=35087)")
  # Oslo has the highest rate (112.4)
  expect_equal(lvls[length(lvls)], "Oslo (N=693494)")
})

test_that("gg: ascending = FALSE puts highest rate first in factor levels", {
  fig  <- hd_make(spec_n, "ranked_bar", opts,
                  backend = "ggplot2", ascending = FALSE)
  lvls <- .gg_xlevels(fig)
  expect_equal(lvls[1], "Oslo (N=693494)")
  expect_equal(lvls[length(lvls)], "Porsgrunn (N=35087)")
})

test_that("gg: default ascending is TRUE", {
  fig_default <- hd_make(spec_n, "ranked_bar", opts, backend = "ggplot2")
  fig_asc     <- hd_make(spec_n, "ranked_bar", opts,
                          backend = "ggplot2", ascending = TRUE)
  expect_equal(.gg_xlevels(fig_default), .gg_xlevels(fig_asc))
})

test_that("gg: all 20 municipalities present in factor levels", {
  fig  <- hd_make(spec_n, "ranked_bar", opts, backend = "ggplot2")
  lvls <- .gg_xlevels(fig)
  expect_length(lvls, 20L)
})


# ═══════════════════════════════════════════════════════════════════════════════
# 3. N= labels in x axis — gg backend
# ═══════════════════════════════════════════════════════════════════════════════

test_that("gg: spec$n appends (N=...) to x labels", {
  fig  <- hd_make(spec_n, "ranked_bar", opts, backend = "ggplot2")
  lvls <- .gg_xlevels(fig)
  # Every level should contain "(N="
  expect_true(all(grepl("(N=", lvls, fixed = TRUE)))
})

test_that("gg: without spec$n, x labels are plain municipality names", {
  fig  <- hd_make(spec_no_n, "ranked_bar", opts, backend = "ggplot2")
  lvls <- .gg_xlevels(fig)
  expect_false(any(grepl("(N=", lvls, fixed = TRUE)))
  expect_true("Oslo" %in% lvls)
})


# ═══════════════════════════════════════════════════════════════════════════════
# 4. Comparison highlight — gg backend
#    When comp is set, a .is_comp column drives fill; the fill scale maps
#    TRUE → col2 and FALSE → col1.
# ═══════════════════════════════════════════════════════════════════════════════


test_that("gg: comp adds .is_comp column to bar layer data", {
  fig     <- hd_make(spec_n, "ranked_bar", opts,
                     backend = "ggplot2", comp = "Oslo")
  bar_idx <- which(vapply(fig$layers, function(l)
    inherits(l$geom, "GeomBar"), logical(1)))
  bar_data <- fig$layers[[bar_idx]]$data
  expect_true(".is_comp" %in% names(bar_data))
  # Exactly one row should be marked as the comparison bar
  expect_equal(sum(bar_data$.is_comp), 1L)
})

test_that("gg: comp = NULL produces no .is_comp column", {
  fig     <- hd_make(spec_n, "ranked_bar", opts, backend = "ggplot2")
  bar_idx <- which(vapply(fig$layers, function(l)
    inherits(l$geom, "GeomBar"), logical(1)))
  bar_data <- fig$layers[[bar_idx]]$data
  expect_false(".is_comp" %in% names(bar_data))
})

test_that("gg: comp produces two distinct fill colours in built plot", {
  # Test via ggplot_build() — avoids ggplot2 internal class names entirely.
  # Two fill colours means the highlight scale was applied correctly.
  fig     <- hd_make(spec_n, "ranked_bar", opts,
                     backend = "ggplot2", comp = "Oslo")
  built   <- ggplot2::ggplot_build(fig)
  bar_idx <- which(vapply(fig$layers, function(l)
    inherits(l$geom, "GeomBar"), logical(1)))
  fill_vals <- unique(built$data[[bar_idx]]$fill)
  expect_length(fill_vals, 2L)
})

test_that("gg: comp = NULL produces a single fill colour in built plot", {
  fig     <- hd_make(spec_n, "ranked_bar", opts, backend = "ggplot2")
  built   <- ggplot2::ggplot_build(fig)
  bar_idx <- which(vapply(fig$layers, function(l)
    inherits(l$geom, "GeomBar"), logical(1)))
  fill_vals <- unique(built$data[[bar_idx]]$fill)
  expect_length(fill_vals, 1L)
})

test_that("gg: partial comp match works (grepl, fixed = TRUE)", {
  # "Oslo" matches "Oslo" exactly — but also test a substring match
  fig      <- hd_make(spec_n, "ranked_bar", opts,
                      backend = "ggplot2", comp = "Ber")   # matches Bergen
  bar_idx  <- which(vapply(fig$layers, function(l)
    inherits(l$geom, "GeomBar"), logical(1)))
  bar_data <- fig$layers[[bar_idx]]$data
  comp_rows <- bar_data[bar_data$.is_comp, ]
  expect_equal(nrow(comp_rows), 1L)
  expect_true(grepl("Bergen", comp_rows$.xname[1], fixed = TRUE))
})


# ═══════════════════════════════════════════════════════════════════════════════
# 5. Aim line — gg backend
# ═══════════════════════════════════════════════════════════════════════════════

## test_that("gg: aim adds a GeomHline layer", {                     ##
##   fig <- hd_make(spec_n, "ranked_bar", opts,                      ##
##                  backend = "ggplot2", aim = 80)                   ##
##   hline_layers <- Filter(function(l)                              ##
##     inherits(l$geom, "GeomHline"), fig$layers)                    ##
##   expect_length(hline_layers, 1L)                                 ##
## })                                                                ##
##                                                                   ##
## test_that("gg: aim line sits at the correct yintercept", {        ##
##   aim_val   <- 80                                                 ##
##   fig       <- hd_make(spec_n, "ranked_bar", opts,                ##
##                        backend = "ggplot2", aim = aim_val)        ##
##   built     <- ggplot2::ggplot_build(fig)                         ##
##   hline_idx <- which(vapply(fig$layers, function(l)               ##
##     inherits(l$geom, "GeomHline"), logical(1)))                   ##
##   yint <- unique(built$data[[hline_idx]]$yintercept)              ##
##   expect_equal(yint, aim_val)                                     ##
## })                                                                ##
##                                                                   ##
## test_that("gg: aim = NULL adds no GeomHline layer", {             ##
##   fig <- hd_make(spec_n, "ranked_bar", opts, backend = "ggplot2") ##
##   hline_layers <- Filter(function(l)                              ##
##     inherits(l$geom, "GeomHline"), fig$layers)                    ##
##   expect_length(hline_layers, 0L)                                 ##
## })                                                                ##


# ═══════════════════════════════════════════════════════════════════════════════
# 6. Flip — gg backend
#    After the fix, gg_ranked_bar appends coord_flip() as a layer when
#    do_flip = TRUE, and base_fig is prevented from adding a second one.
# ═══════════════════════════════════════════════════════════════════════════════

test_that("gg: flip = TRUE (default) adds CoordFlip", {
  optsFlip    <- hd_opts(title = "Rate by municipality", ylab = "Rate per 100 000", flip = TRUE)
  fig <- hd_make(spec_n, "ranked_bar", optsFlip, backend = "ggplot2")
  expect_true(inherits(fig$coordinates, "CoordFlip"))
})

test_that("gg: flip = FALSE does not add CoordFlip", {
  optsFlip    <- hd_opts(title = "Rate by municipality", ylab = "Rate per 100 000", flip = FALSE)
  fig <- hd_make(spec_n, "ranked_bar", optsFlip,
                 backend = "ggplot2")
  expect_false(inherits(fig$coordinates, "CoordFlip"))
})


# ═══════════════════════════════════════════════════════════════════════════════
# 7. spec$data is never mutated
#    gg_ranked_bar must work on a local copy of spec$data.
# ═══════════════════════════════════════════════════════════════════════════════

test_that("gg: spec$data columns are unchanged after hd_make", {
  cols_before <- names(spec_n$data)
  hd_make(spec_n, "ranked_bar", opts, backend = "ggplot2",
          comp = "Oslo", aim = 80)
  expect_equal(names(spec_n$data), cols_before)
})

test_that("hc: spec$data columns are unchanged after hd_make", {
  cols_before <- names(spec_n$data)
  hd_make(spec_n, "ranked_bar", opts, backend = "highcharter")
  expect_equal(names(spec_n$data), cols_before)
})


# ═══════════════════════════════════════════════════════════════════════════════
# 8. HC backend — series structure
# ═══════════════════════════════════════════════════════════════════════════════

.hc_series <- function(fig) fig$x$hc_opts$series

test_that("hc: produces exactly one series", {
  fig <- hd_make(spec_n, "ranked_bar", opts, backend = "highcharter")
  expect_length(.hc_series(fig), 1L)
})

test_that("hc: series type is bar", {
  fig <- hd_make(spec_n, "ranked_bar", opts, backend = "highcharter")
  expect_equal(.hc_series(fig)[[1]]$type, "bar")
})

test_that("hc: series has one data point per row", {
  fig <- hd_make(spec_n, "ranked_bar", opts, backend = "highcharter")
  expect_length(.hc_series(fig)[[1]]$data, nrow(muni_df))
})

test_that("hc: each point has name, y, and color fields", {
  fig    <- hd_make(spec_n, "ranked_bar", opts, backend = "highcharter")
  points <- .hc_series(fig)[[1]]$data
  has_all <- vapply(points, function(p)
    all(c("name", "y", "color") %in% names(p)), logical(1))
  expect_true(all(has_all))
})

test_that("hc: point y values match original rate column (all present)", {
  fig    <- hd_make(spec_n, "ranked_bar", opts, backend = "highcharter")
  points <- .hc_series(fig)[[1]]$data
  y_vals <- vapply(points, `[[`, numeric(1), "y")
  expect_setequal(y_vals, muni_df$rate)
})


# ═══════════════════════════════════════════════════════════════════════════════
# 9. HC backend — sorting
# ═══════════════════════════════════════════════════════════════════════════════

test_that("hc: ascending = TRUE sorts lowest rate first", {
  fig    <- hd_make(spec_n, "ranked_bar", opts,
                    backend = "highcharter", ascending = TRUE)
  points <- .hc_series(fig)[[1]]$data
  y_vals <- vapply(points, `[[`, numeric(1), "y")
  expect_equal(y_vals, sort(muni_df$rate, decreasing = FALSE))
})

test_that("hc: ascending = FALSE sorts highest rate first", {
  fig    <- hd_make(spec_n, "ranked_bar", opts,
                    backend = "highcharter", ascending = FALSE)
  points <- .hc_series(fig)[[1]]$data
  y_vals <- vapply(points, `[[`, numeric(1), "y")
  expect_equal(y_vals, sort(muni_df$rate, decreasing = TRUE))
})


# ═══════════════════════════════════════════════════════════════════════════════
# 10. HC backend — N in point data (tooltip)
#     After the label-cleanup change: N lives in point$n_obs, not in the name.
# ═══════════════════════════════════════════════════════════════════════════════

test_that("hc: with spec$n, each point has n_obs field", {
  fig    <- hd_make(spec_n, "ranked_bar", opts, backend = "highcharter")
  points <- .hc_series(fig)[[1]]$data
  has_n  <- vapply(points, function(p) "n_obs" %in% names(p), logical(1))
  expect_true(all(has_n))
})

test_that("hc: with spec$n, n_obs values match pop_count column", {
  fig    <- hd_make(spec_n, "ranked_bar", opts, backend = "highcharter")
  points <- .hc_series(fig)[[1]]$data
  n_vals <- vapply(points, `[[`, numeric(1), "n_obs")
  expect_setequal(n_vals, muni_df$pop_count)
})

test_that("hc: without spec$n, points have no n_obs field", {
  fig    <- hd_make(spec_no_n, "ranked_bar", opts, backend = "highcharter")
  points <- .hc_series(fig)[[1]]$data
  has_n  <- vapply(points, function(p) "n_obs" %in% names(p), logical(1))
  expect_false(any(has_n))
})

test_that("hc: with spec$n, point names do NOT contain '(N='", {
  # After the label-cleanup change, N is in n_obs only — not in the name field
  fig    <- hd_make(spec_n, "ranked_bar", opts, backend = "highcharter")
  points <- .hc_series(fig)[[1]]$data
  names  <- vapply(points, `[[`, character(1), "name")
  expect_false(any(grepl("(N=", names, fixed = TRUE)))
})


# ═══════════════════════════════════════════════════════════════════════════════
# 11. HC backend — comparison highlight colours
# ═══════════════════════════════════════════════════════════════════════════════

test_that("hc: comp highlights exactly one bar with a different colour", {
  fig    <- hd_make(spec_n, "ranked_bar", opts,
                    backend = "highcharter", comp = "Oslo")
  points <- .hc_series(fig)[[1]]$data
  colors <- vapply(points, `[[`, character(1), "color")
  # Exactly one point should have the highlight (col2) colour
  n_unique <- length(unique(colors))
  expect_equal(n_unique, 2L)
  # Exactly one point gets the minority colour
  minority_col <- names(sort(table(colors)))[1]
  expect_equal(sum(colors == minority_col), 1L)
})

test_that("hc: comp = NULL uses a single colour for all bars", {
  fig    <- hd_make(spec_n, "ranked_bar", opts, backend = "highcharter")
  points <- .hc_series(fig)[[1]]$data
  colors <- vapply(points, `[[`, character(1), "color")
  expect_length(unique(colors), 1L)
})

test_that("hc: highlighted point name matches comp string", {
  fig    <- hd_make(spec_n, "ranked_bar", opts,
                    backend = "highcharter", comp = "Bergen")
  points <- .hc_series(fig)[[1]]$data
  colors <- vapply(points, `[[`, character(1), "color")
  names  <- vapply(points, `[[`, character(1), "name")
  minority_col  <- names(sort(table(colors)))[1]
  highlighted   <- names[colors == minority_col]
  expect_true(grepl("Bergen", highlighted, fixed = TRUE))
})


# ═══════════════════════════════════════════════════════════════════════════════
# 12. HC backend — aim line
# ═══════════════════════════════════════════════════════════════════════════════

.hc_yaxis <- function(fig) fig$x$hc_opts$yAxis

test_that("hc: aim adds a plotLines entry to yAxis", {
  fig   <- hd_make(spec_n, "ranked_bar", opts,
                   backend = "highcharter", aim = 80)
  yaxis <- .hc_yaxis(fig)
  plot_lines <- yaxis$plotLines %||% yaxis[[1]]$plotLines
  expect_true(!is.null(plot_lines) && length(plot_lines) > 0)
})

test_that("hc: aim plotLine value matches the aim argument", {
  aim_val   <- 80
  fig       <- hd_make(spec_n, "ranked_bar", opts,
                       backend = "highcharter", aim = aim_val)
  yaxis     <- .hc_yaxis(fig)
  plot_lines <- yaxis$plotLines %||% yaxis[[1]]$plotLines
  line_values <- vapply(plot_lines, `[[`, numeric(1), "value")
  expect_true(aim_val %in% line_values)
})

test_that("hc: aim = NULL adds no plotLines", {
  fig   <- hd_make(spec_n, "ranked_bar", opts, backend = "highcharter")
  yaxis <- .hc_yaxis(fig)
  plot_lines <- yaxis$plotLines %||% yaxis[[1]]$plotLines
  expect_true(is.null(plot_lines) || length(plot_lines) == 0)
})


# ═══════════════════════════════════════════════════════════════════════════════
# 13. HC backend — tooltip
#     After the label-cleanup: hc_ranked_bar sets its own hc_tooltip().
# ═══════════════════════════════════════════════════════════════════════════════

.hc_tooltip <- function(fig) fig$x$hc_opts$tooltip

test_that("hc: with spec$n, tooltip pointFormat contains {point.n_obs}", {
  fig <- hd_make(spec_n, "ranked_bar", opts, backend = "highcharter")
  tt  <- .hc_tooltip(fig)
  expect_true(grepl("point.n_obs", tt$pointFormat, fixed = TRUE))
})

test_that("hc: without spec$n, tooltip pointFormat has no {point.n_obs}", {
  fig <- hd_make(spec_no_n, "ranked_bar", opts, backend = "highcharter")
  tt  <- .hc_tooltip(fig)
  expect_false(grepl("point.n_obs", tt$pointFormat, fixed = TRUE))
})

test_that("hc: tooltip pointFormat contains {point.y}", {
  fig <- hd_make(spec_n, "ranked_bar", opts, backend = "highcharter")
  tt  <- .hc_tooltip(fig)
  expect_true(grepl("point.y", tt$pointFormat, fixed = TRUE))
})

test_that("hc: dataLabels are disabled on the series", {
  fig    <- hd_make(spec_n, "ranked_bar", opts, backend = "highcharter")
  series <- .hc_series(fig)[[1]]
  dl_enabled <- series$dataLabels$enabled %||% TRUE   # default in HC is TRUE
  expect_false(isTRUE(dl_enabled))
})


# ═══════════════════════════════════════════════════════════════════════════════
# 14. grepl NULL guard — the comp = NULL bug must not regress
# ═══════════════════════════════════════════════════════════════════════════════

test_that("hc: comp = NULL does not error (grepl NULL guard)", {
  expect_no_error(
    hd_make(spec_n, "ranked_bar", opts, backend = "highcharter", comp = NULL)
  )
})

test_that("gg: comp = NULL does not error (grepl NULL guard)", {
  expect_no_error(
    hd_make(spec_n, "ranked_bar", opts, backend = "ggplot2", comp = NULL)
  )
})

test_that("hc: comp = '' (empty string) does not error", {
  expect_no_error(
    hd_make(spec_n, "ranked_bar", opts, backend = "highcharter", comp = "")
  )
})

test_that("gg: comp = '' (empty string) does not error", {
  expect_no_error(
    hd_make(spec_n, "ranked_bar", opts, backend = "ggplot2", comp = "")
  )
})

test_that("hc: comp that matches nothing is silently ignored", {
  fig    <- hd_make(spec_n, "ranked_bar", opts,
                    backend = "highcharter", comp = "XXXXXX")
  points <- .hc_series(fig)[[1]]$data
  colors <- vapply(points, `[[`, character(1), "color")
  # No highlight → single colour
  expect_length(unique(colors), 1L)
})


# ═══════════════════════════════════════════════════════════════════════════════
# 15. Label placement helpers (gg only)
#     ypos logic: inside labels (ypos = 1) get hjust = 1.5 / white text;
#     outside labels (ypos = 0) get hjust = -0.5 / dark text.
# ═══════════════════════════════════════════════════════════════════════════════

test_that("gg: at least one GeomText layer is present", {
  fig  <- hd_make(spec_n, "ranked_bar", opts, backend = "ggplot2")
  text_layers <- Filter(function(l)
    inherits(l$geom, "GeomText"), fig$layers)
  expect_gte(length(text_layers), 1L)
})

test_that("gg: inside label layer uses white text colour", {
  fig  <- hd_make(spec_n, "ranked_bar", opts, backend = "ggplot2")
  text_layers <- Filter(function(l)
    inherits(l$geom, "GeomText"), fig$layers)
  # At least one layer should use white (#FFFFFF) — the inside label layer
  colours <- vapply(text_layers, function(l)
    l$aes_params$colour %||% "", character(1))
  expect_true(any(colours == "#FFFFFF"))
})

## test_that("gg: outside label layer uses dark text colour", {       ##
##   fig  <- hd_make(spec_n, "ranked_bar", opts, backend = "ggplot2") ##
##   text_layers <- Filter(function(l)                                ##
##     inherits(l$geom, "GeomText"), fig$layers)                      ##
##   colours <- vapply(text_layers, function(l)                       ##
##     l$aes_params$colour %||% "", character(1))                     ##
##   expect_true(any(colours == "#555555"))                           ##
## })                                                                 ##


# ═══════════════════════════════════════════════════════════════════════════════
# 16. xAxis categories — HC backend
# ═══════════════════════════════════════════════════════════════════════════════

test_that("hc: xAxis categories length matches number of rows", {
  fig  <- hd_make(spec_n, "ranked_bar", opts, backend = "highcharter")
  cats <- fig$x$hc_opts$xAxis$categories
  expect_length(cats, nrow(muni_df))
})

test_that("hc: xAxis categories are plain names (no N= suffix)", {
  fig  <- hd_make(spec_n, "ranked_bar", opts, backend = "highcharter")
  cats <- fig$x$hc_opts$xAxis$categories
  # After the label-cleanup: N is in n_obs only — axis labels must be plain
  expect_false(any(grepl("(N=", cats, fixed = TRUE)))
})

test_that("hc: xAxis categories contain all municipality names", {
  fig  <- hd_make(spec_n, "ranked_bar", opts, backend = "highcharter")
  cats <- fig$x$hc_opts$xAxis$categories
  expect_setequal(cats, muni_df$municipality)
})
