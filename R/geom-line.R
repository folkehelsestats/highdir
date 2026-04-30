# ════════════════════════════════════════════════════════════════════════════
# LINE / SPLINE
# ════════════════════════════════════════════════════════════════════════════
#
# Optional arguments (all via geom_params, never hard-coded in hd_make):
#
#   smooth       Logical.  TRUE = spline/loess, FALSE = straight line + points.
#                Default TRUE.  Both backends.
#   dot_size     Numeric.  Marker radius (px for HC, ggplot size / 3 for gg).
#                Default 4.  Both backends.
#   line_symbols Character vector.  Per-group Highcharts marker shapes.
#                Default NULL (uses resolve_symbols()).  Highcharter only —
#                gg_line silently ignores it.
#
# These three are documented in the registry (zzz.R) under optional_args so
# that geom_args("line") shows them to users.  The geom functions themselves
# apply the defaults via `geom_params$key %||% default` — the registry entry
# is for discoverability only, not enforcement.
#
# Why smooth and dot_size are NOT named params of hd_make():
#   They belong to the line geometry, not to hd_make() itself.  Adding them
#   to hd_make()'s signature would mean every column/pie/map caller sees them
#   in autocomplete even though they are irrelevant.  Passing them via `...`
#   keeps hd_make() closed for modification when new geoms are added.
#
# Why line_symbols IS still accepted via `...` and not a hard-coded param:
#   Same reason — it is geom-specific.  It was previously a named param of
#   hd_make() but has been moved to `...` alongside smooth and dot_size.
# ════════════════════════════════════════════════════════════════════════════

#' @keywords internal
gg_line <- function(spec, opts, geom_params) {

  # Read from geom_params with fallback defaults.
  # These defaults must match what is registered in zzz.R optional_args
  # so that geom_args("line") shows the same values the geom actually uses.
  sc       <- geom_params$single_colour   # set by ggplot_engine for no-group specs
  smooth   <- geom_params$smooth   %||% TRUE
  size     <- geom_params$dot_size  %||% 4L

  # line_symbols is intentionally NOT read here — it is a Highcharts concept
  # (named marker shapes like "circle", "square").  ggplot2 uses shape
  # integers via scale_shape, which is handled by apply_gg_colors().
  # Passing line_symbols to the ggplot2 backend is therefore silently ignored,
  # which is the intended behaviour.

  if (!is.null(sc)) {
    # Single-series path: colour injected directly so no scale conflict
    layers <- list(
      ggplot2::geom_line(colour = sc, linewidth = 0.8),
      ggplot2::geom_point(colour = sc, size = size / 3)
    )
    if (smooth)
      layers <- c(layers, list(
        ggplot2::geom_smooth(method = "loess", formula = y ~ x,
                             se = FALSE, colour = sc,
                             linewidth = 0.5, linetype = "dashed")
      ))
  } else {
    # Multi-series path: colour comes from apply_gg_colors() in ggplot_engine
    layers <- list(
      ggplot2::geom_line(linewidth = 0.8),
      ggplot2::geom_point(size = size / 3)
    )
    if (smooth)
      layers <- c(layers, list(
        ggplot2::geom_smooth(method = "loess", formula = y ~ x,
                             se = FALSE, linewidth = 0.5,
                             linetype = "dashed")
      ))
  }

  layers
}


#' @keywords internal
hc_line <- function(chart, spec, opts, geom_params, use_js = TRUE, ...) {
    # Read optional args from geom_params with fallback defaults.
    # Defaults must match zzz.R optional_args for geom_args("line") accuracy.
    smooth <- geom_params$smooth %||% TRUE
    dot_size <- geom_params$dot_size %||% 4
    symbols <- geom_params$line_symbols # NULL → resolve_symbols() picks automatically

    groups <- .group_split(spec)
    palette <- resolve_colors(length(groups), opts$colors)
    syms <- resolve_symbols(length(groups), symbols)
    point_ev <- point_events_or_null(use_js)
    xmap <- .hc_x_map(spec)

    # smooth = TRUE  → Highcharts "spline" type (cubic interpolation)
    # smooth = FALSE → Highcharts "line"   type (straight segments)
    ctype <- if (smooth) "spline" else "line"

    for (i in seq_along(groups)) {
        grp <- groups[[i]]
        args <- list(
            chart,
            data      = xmap$data[grp$rows, ],
            type      = ctype,
            name      = grp$name,
            xmap$mapping,
            color     = palette[i],
            lineWidth = 2,
            marker    = list(symbol = syms[i], enabled = TRUE, radius = dot_size),
            states    = list(hover = list(lineWidth = 3))
        )
        if (!is.null(point_ev)) args$point <- point_ev
        chart <- do.call(highcharter::hc_add_series, args)
    }
    chart
}


## -----------------------------------------------------------------------------
## Public constructor
## -----------------------------------------------------------------------------
##

#' Line Geometry Layer for hd Objects
#'
#' `hd_geom_line()` creates a line geometry layer that is added to an [hd()]
#' object via `+`.  The layer records the geometry type and any geometry-specific arguments;
#' rendering only happens when the `hd` object is printed.
#'
#' @param smooth Logical. TRUE = spline curves, FALSE = straight segments. Both backends.
#' @param dot_size Numeric. Marker radius in pixels. Both backends.
#' @param line_symbols Character vector. Highcharter only. Per-group marker shapes:
#'  "circle", "square", "diamond", "triangle", "triangle-down".
#' @param ... Geometry-specific arguments forwarded to [hd_make()].
#'
#' @return An S3 object of class `"hd_geom"` for use with `+.hd`.
#'
#' @examples
#' # Single series - no group column
#' spec_line1 <- hd_spec(alco1,
#'     x    = "year",
#'     y    = "adj_mean"
#' )
#'
#' opts_line <- hd_opts(
#'     title = "Alcohol consumption over time",
#'     subtitle = "Source: Norwegian Directorate of Health",
#'     ylim = c(0, 50),
#'     ylab = "Litres per capita"
#' )
#'
#'
#' # Straight segments
#' hd_make(spec_line1, "line", opts_line, smooth = FALSE)
#'
#' # Composite example with multiple geoms and custom line symbols
#' hd(alco2, x = "year", y = "adj_mean", group = "kjonn", backend = "ggplot2") +
#'   hd_geom_line(smooth = TRUE, dot_size = 3) +
#'   hd_opts(title = "Alcohol consumption over time by kjonn", subtitle = "Source: Norwegian Directorate of Health")
#'
#' @export
hd_geom_line <- function(smooth, dot_size, line_symbols,...) {
  hd_geom("line", smooth = smooth, dot_size = dot_size, line_symbols = line_symbols, ...)
}
