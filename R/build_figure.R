#' Build Figure
#'
#' Build a highcharter plot from specification.
#'
#' @param spec fig_spec object
#' @param type Geometry type
#' @param ... Additional geometry arguments
#'
#' @return highchart object
#' @export
build_fig <- function(spec, type, ...) {
  UseMethod("build_fig")
}

#' @export
build_fig.fig_spec <- function(spec, type, ...) {

  geom <- get_geom(type)

  if (is.null(geom)) stop("Unknown geometry")

  chart <- base_fig(spec)

  args <- list(chart = chart, spec = spec, ...)

  do.call(geom$fun, args)
}
