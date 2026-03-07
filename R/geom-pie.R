
# ════════════════════════════════════════════════════════════════════════════
# PIE
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

# For a pie chart:
#   spec$x → slice label column
#   spec$y → slice value column
#   spec$group is ignored (a pie shows one series)
#
# ggplot2: geom_col() + coord_polar("y") — the classic polar-bar pie.
# highcharter: a single "pie" type series where each slice name comes from x.

#' @keywords internal
gg_pie <- function(spec, opts, geom_params, ...) {
  # ggplot2 pie = stacked bar in polar coordinates.
  # We re-map: fill = x (the label column), y = y (the value column).
  # The base canvas already has x/y mapped; we override with a coord_polar.
  list(
    ggplot2::aes(x = "", fill = .data[[spec$x]],
                 y = .data[[spec$y]]),
    ggplot2::geom_bar(stat = "identity", width = 1, colour = "white",
                      linewidth = 0.4),
    ggplot2::coord_polar(theta = "y"),
    ggplot2::labs(x = NULL, y = NULL),
    ggplot2::theme_void(),
    ggplot2::theme(legend.position = "right")
  )
}

## # Pie is always single-series from ggplot2's perspective but uses ##
## # fill to distinguish slices — single_colour is ignored here.     ##
## gg_pie <- function(spec, opts, geom_params) {                     ##
##   list(                                                           ##
##     ggplot2::geom_bar(                                            ##
##       ggplot2::aes(x    = "",                                     ##
##                    y    = .data[[spec$y]],                        ##
##                    fill = .data[[spec$x]]),                       ##
##       stat     = "identity",                                      ##
##       width    = 1,                                               ##
##       position = "stack"                                          ##
##     ),                                                            ##
##     ggplot2::coord_polar("y", start = 0),                         ##
##     ggplot2::theme_void()                                         ##
##   )                                                               ##
## }                                                                 ##


#' @keywords internal
hc_pie <- function(chart, spec, opts, geom_params, use_js = TRUE, ...) {
  inner_size <- geom_params$inner_size %||% "0%"   # "50%" = donut
  df      <- spec$data
  labels  <- df[[spec$x]]
  values  <- df[[spec$y]]
  palette <- resolve_colors(length(labels), opts$colors)

  # Build the data list Highcharts expects for a pie series
  pie_data <- lapply(seq_len(nrow(df)), function(i)
    list(name  = as.character(labels[i]),
         y     = values[i],
         color = palette[i]))

  chart |>
    highcharter::hc_add_series(
      type      = "pie",
      name      = spec$ylab,
      data      = pie_data,
      innerSize = inner_size,
      dataLabels = list(
        enabled = TRUE,
        format  = "<b>{point.name}</b>: {point.percentage:.1f}%"
      )
    )
}
