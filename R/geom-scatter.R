#' @keywords internal
gg_scatter <- function(spec, ...) {
  ggplot2::geom_point(...)
}

hc_scatter <- function(chart, spec, ...) {
  highcharter::hc_add_series(
    chart,
    data = spec$data,
    type = "scatter",
    highcharter::hcaes_string(x = spec$x, y = spec$y),
    ...
  )
}
