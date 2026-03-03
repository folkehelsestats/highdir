# ════════════════════════════════════════════════════════════════════════════
# LINE / SPLINE
# ════════════════════════════════════════════════════════════════════════════
# Each geometry is a pair:
#   gg_<name>  → returns a ggplot2 layer (or list of layers)
#   hc_<name>  → adds series to a highchart object, returns the updated chart
#
# Calling convention (enforced by the registry):
#   gg_*:  function(spec, opts, geom_params, ...)
#   hc_*:  function(chart, spec, opts, geom_params, use_js, ...)
#
# geom_params is a named list carrying all geom-specific args so that the
# engine signature stays stable as new geoms are added.  Nothing leaks into
# hc_add_series() via bare `...`.

#' @keywords internal
gg_line <- function(spec, opts, geom_params, ...) {
  smooth   <- isTRUE(geom_params$smooth)
  dot_size <- geom_params$dot_size %||% 4

  if (smooth) {
    if (requireNamespace("ggforce", quietly = TRUE))
      return(list(ggforce::geom_bspline(linewidth = 0.8)))
    return(list(ggplot2::geom_line(linewidth = 0.8)))
  }
  list(ggplot2::geom_line(linewidth = 0.8),
       ggplot2::geom_point(size = dot_size))
}

#' @keywords internal
hc_line <- function(chart, spec, opts, geom_params, use_js = TRUE, ...) {
  smooth   <- isTRUE(geom_params$smooth)
  dot_size <- geom_params$dot_size     %||% 4
  symbols  <- geom_params$line_symbols
  groups   <- .group_split(spec)
  palette  <- resolve_colors(length(groups), opts$colors)
  syms     <- resolve_symbols(length(groups), symbols)
  point_ev <- point_events_or_null(use_js)
  xmap     <- .hc_x_map(spec)
  ctype    <- if (smooth) "spline" else "line"

  for (i in seq_along(groups)) {
    grp  <- groups[[i]]
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
