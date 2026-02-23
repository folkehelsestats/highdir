
.geom_registry <- new.env(parent = emptyenv())


#' Register Geometry
#'
#' @param name Geometry name.
#' @param fun Function implementing geometry.
#' @param required_args Character vector of required arguments.
#' @export
register_geom <- function(name, fun, required_args = character()) {
  .geom_registry[[name]] <- list(
    fun = fun,
    required_args = required_args
  )
}

#' List Available Geometries
#' @export
list_geoms <- function() {
  ls(.geom_registry)
}

#' Get Geometry Metadata
#' @export
get_geom <- function(name) {
  .geom_registry[[name]]
}
