#' @keywords internal
gg_line <- function(spec, ...) {
  ggplot2::geom_line(...)
}

hc_line <- function(chart, spec, ...) {
  highcharter::hc_add_series(
    chart,
    data = spec$data,
    type = "line",
    highcharter::hcaes_string(x = spec$x, y = spec$y),
    ...
  )
}
