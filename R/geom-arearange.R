# ════════════════════════════════════════════════════════════════════════════
# AREARANGE
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
gg_arearange <- function(spec, opts, geom_params, ...) {
  ymin <- geom_params$ymin
  ymax <- geom_params$ymax
  list(ggplot2::geom_ribbon(
    ggplot2::aes(ymin = .data[[ymin]], ymax = .data[[ymax]]),
    alpha = 0.3
  ))
}

#' @keywords internal
hc_arearange <- function(chart, spec, opts, geom_params, use_js = TRUE, ...) {
  ymin     <- geom_params$ymin
  ymax     <- geom_params$ymax
  groups   <- .group_split(spec)
  palette  <- resolve_colors(length(groups), opts$colors)
  point_ev <- point_events_or_null(use_js)

  for (i in seq_along(groups)) {
    grp  <- groups[[i]]
    args <- list(
      chart,
      data  = spec$data[grp$rows, ],
      type  = "arearange",
      name  = grp$name,
      highcharter::hcaes(x    = !!rlang::sym(spec$x),
                          low  = !!rlang::sym(ymin),
                          high = !!rlang::sym(ymax)),
      color = palette[i]
    )
    if (!is.null(point_ev)) args$point <- point_ev
    chart <- do.call(highcharter::hc_add_series, args)
  }
  chart
}
