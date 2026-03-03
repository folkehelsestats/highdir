# ════════════════════════════════════════════════════════════════════════════
# COLUMN
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
gg_column <- function(spec, opts, geom_params, ...) {
  list(ggplot2::geom_col(position = "dodge"))
}

#' @keywords internal
hc_column <- function(chart, spec, opts, geom_params, use_js = TRUE, ...) {
  groups   <- .group_split(spec)
  palette  <- resolve_colors(length(groups), opts$colors)
  point_ev <- point_events_or_null(use_js)
  xmap     <- .hc_x_map(spec)

  for (i in seq_along(groups)) {
    grp  <- groups[[i]]
    args <- list(
      chart,
      data   = xmap$data[grp$rows, ],
      type   = "column",
      name   = grp$name,
      xmap$mapping,
      color  = palette[i],
      states = list(hover = list(brightness = 0.2))
    )
    if (!is.null(point_ev)) args$point <- point_ev
    chart <- do.call(highcharter::hc_add_series, args)
  }
  chart
}
