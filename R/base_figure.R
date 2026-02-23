#' Base Highchart
#'
#' @param spec fig_spec object
#' @return highchart object
#' @keywords internal
base_fig <- function(spec) {

  highcharter::highchart() |>
    highcharter::hc_xAxis(title = list(text = spec$xlab)) |>
    highcharter::hc_yAxis(title = list(text = spec$ylab))
}
