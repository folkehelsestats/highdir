#' Base Figure
#'
#' Constructs backend base object.
#'
#' @param spec A fig_spec object.
#' @param backend Backend name.
#' @export
base_fig <- function(spec, backend) {

  if (backend == "ggplot2") {
    ggplot2::ggplot(
      spec$data,
      ggplot2::aes_(spec$x, spec$y)
    ) +
      ggplot2::labs(
        x = spec$xlab,
        y = spec$ylab
      )
  }

  else if (backend == "highcharter") {
    highcharter::highchart() |>
      highcharter::hc_xAxis(title = list(text = spec$xlab)) |>
      highcharter::hc_yAxis(title = list(text = spec$ylab))
  }

  else stop("Unknown backend")
}
