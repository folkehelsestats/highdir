#' @keywords internal
gg_arearange <- function(spec, ymin, ymax, ...) {

  ggplot2::geom_ribbon(
    ggplot2::aes_string(ymin = ymin, ymax = ymax),
    alpha = 0.3
  )
}

hc_arearange <- function(chart, spec, ymin, ymax, ...) {

  highcharter::hc_add_series(
    chart,
    data = spec$data,
    type = "arearange",
    highcharter::hcaes_string(x = spec$x, low = ymin, high = ymax),
    ...
  )
}
