.backend_registry <- new.env(parent = emptyenv())

#' Register Backend
#'
#' Registers a rendering backend engine.
#'
#' @param name Backend name.
#' @param engine A function(spec, geom_fun, ...)
#' @export
register_backend <- function(name, engine) {
  .backend_registry[[name]] <- engine
}

get_backend <- function(name) {
  .backend_registry[[name]]
}

#' List Backends
#'
#' Lists all registered backends.
#' @export
list_backends <- function() {
  ls(.backend_registry)
}
