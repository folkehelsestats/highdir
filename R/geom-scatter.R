
# ════════════════════════════════════════════════════════════════════════════
# SCATTER
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
gg_scatter <- function(spec, opts, geom_params) {
  sc   <- geom_params$single_colour
  size <- geom_params$dot_size %||% 4L

  if (!is.null(sc)) {
    list(ggplot2::geom_point(colour = sc, fill = sc,
                              size = size / 3, shape = 21))
  } else {
    list(ggplot2::geom_point(size = size / 3, shape = 21))
  }
}

#' @keywords internal
hc_scatter <- function(chart, spec, opts, geom_params, use_js = TRUE, ...) {
  groups   <- .group_split(spec)
  palette  <- resolve_colors(length(groups), opts$colors)
  point_ev <- point_events_or_null(use_js)
  mapping  <- highcharter::hcaes(x = !!rlang::sym(spec$x),
                                   y = !!rlang::sym(spec$y))

  for (i in seq_along(groups)) {
    grp  <- groups[[i]]
    args <- list(
      chart,
      data  = spec$data[grp$rows, ],
      type  = "scatter",
      name  = grp$name,
      mapping,
      color = palette[i]
    )
    if (!is.null(point_ev)) args$point <- point_ev
    chart <- do.call(highcharter::hc_add_series, args)
  }
  chart
}
