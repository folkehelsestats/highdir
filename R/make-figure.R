#' Make Figure
#'
#' Builds figure using selected backend.
#'
#' @param spec fig_spec object.
#' @param type Geometry type.
#' @param backend Backend name.
#' @param ... Additional arguments.
#'
#' @export
make_fig <- function(spec,
                     type,
                     backend = "highcharter",
                     ...) {

  geom <- get_geom(type)
  if (is.null(geom))
    stop("Unknown geometry")

  backend_engine <- get_backend(backend)
  if (is.null(backend_engine))
    stop("Unknown backend")

  backend_engine(spec, geom, ...)
}
