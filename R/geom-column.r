#' @keywords internal
gg_column <- function(spec, ...) {
  ggplot2::geom_col(...)
}

hc_column <- function(chart, spec, ...) {
  highcharter::hc_add_series(
    chart,
    data = spec$data,
    type = "column",
    highcharter::hcaes_string(x = spec$x, y = spec$y),
    ...
  )
}
