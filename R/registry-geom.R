.geom_registry <- new.env(parent = emptyenv())

#' Register Geometry
#'
#' @param name Geometry name.
#' @param ggplot_fun Function for ggplot2.
#' @param highcharter_fun Function for highcharter.
#' @param required_args Required arguments.
#' @export
register_geom <- function(name,
                          ggplot_fun = NULL,
                          highcharter_fun = NULL,
                          required_args = character()) {

  .geom_registry[[name]] <- list(
    ggplot_fun = ggplot_fun,
    highcharter_fun = highcharter_fun,
    required_args = required_args
  )
}

get_geom <- function(name) {
  .geom_registry[[name]]
}

#' List Geometries
#'
#' Lists all registered geometries.
#' @export
list_geoms <- function() {
  ls(.geom_registry)
}
